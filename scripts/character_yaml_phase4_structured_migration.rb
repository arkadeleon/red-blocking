#!/usr/bin/env ruby

require "digest/sha1"
require "fileutils"
require "optparse"
require "pathname"
require "psych"
require "yaml"

class CharacterYAMLStructuredMigrator
  ROOT = File.expand_path("..", __dir__)
  DEFAULT_INPUT_DIR = File.join(ROOT, "RedBlocking", "Resources", "CharacterData")
  DEFAULT_OUTPUT_DIR = File.join(ROOT, "tmp", "character_yaml_structured")

  GROUP_DEFINITIONS = [
    ["air_normals", "【空中通常技】"],
    ["ground_normals", "【地上通常技】"],
    ["common_moves", "【特殊入力技】"],
    ["special_moves", "【必殺技】"],
    ["super_arts", "【スーパーアーツ】"]
  ].freeze

  STANDARD_FIELD_MAP = {
    "技名" => "displayName",
    "コマンド" => "command",
    "SC" => "superCancel",
    "ガード" => "guard",
    "BL" => "blocking",
    "発生" => "startup",
    "持続" => "active",
    "硬直" => "recovery",
    "攻撃力" => "damage",
    "ケズリ" => "chipDamage",
    "削りダメージ" => "chipDamage",
    "スタン値" => "stun",
    "削減値" => "stunReduction"
  }.freeze

  NOTE_GROUP_TITLES = [
    "補足",
    "通常",
    "EX",
    "共通",
    "小",
    "中",
    "大",
    "追加入力",
    "追加入力「小」",
    "追加入力「中」",
    "追加入力「大」",
    "追加入力「無し」"
  ].freeze

  class MigrationError < StandardError; end

  def migrate(input_dir: DEFAULT_INPUT_DIR, output_dir: DEFAULT_OUTPUT_DIR)
    roster = load_roster(input_dir)
    FileUtils.mkdir_p(output_dir)

    output_paths = roster.map do |entry|
      document = convert_character(entry, input_dir: input_dir)
      output_path = File.join(output_dir, entry.fetch("resourceName"))
      write_yaml(output_path, document)
      output_path
    end

    verify!(
      roster: roster,
      output_paths: output_paths,
      input_dir: input_dir,
      output_dir: output_dir
    )

    {
      "characterCount" => roster.length,
      "inputDirectory" => relative_path(input_dir),
      "outputDirectory" => relative_path(output_dir),
      "files" => output_paths.sort.map { |path| relative_path(path) }
    }
  end

  private

  def load_roster(input_dir)
    roster_path = File.join(input_dir, "Characters.yml")
    rows = load_yaml_document(roster_path)

    Array(rows).map do |row|
      resource_name = normalize_text(row["Next"])
      display_name = normalize_text(row["RowTitle"])

      raise MigrationError, "Characters.yml contains a roster row without Next." if resource_name.nil?
      raise MigrationError, "Characters.yml contains a roster row without RowTitle for #{resource_name}." if display_name.nil?

      {
        "displayName" => display_name,
        "resourceName" => resource_name
      }
    end
  end

  def convert_character(entry, input_dir:)
    resource_name = entry.fetch("resourceName")
    display_name = entry.fetch("displayName")
    character_path = File.join(input_dir, resource_name)
    sections = Array(load_yaml_document(character_path))

    if sections.length != GROUP_DEFINITIONS.length + 1
      raise MigrationError,
            "#{resource_name} must contain 1 introduction section plus 5 move sections; found #{sections.length}."
    end

    introduction_section = sections.first
    move_sections = sections.drop(1)

    {
      "character" => {
        "id" => normalize_character_id(File.basename(resource_name, ".yml")),
        "displayName" => display_name
      },
      "introduction" => build_introduction(introduction_section, resource_name: resource_name),
      "moveGroups" => move_sections.each_with_index.map do |section, index|
        group_id, expected_title = GROUP_DEFINITIONS[index]
        build_move_group(
          section,
          resource_name: resource_name,
          group_id: group_id,
          expected_title: expected_title
        )
      end
    }
  end

  def build_introduction(section, resource_name:)
    title = normalize_text(section["SectionTitle"])
    rows = fetch_rows(section, context: "#{resource_name} introduction")

    raise MigrationError, "#{resource_name} introduction must have a SectionTitle." if title.nil?
    raise MigrationError, "#{resource_name} introduction must contain exactly 1 row." unless rows.length == 1

    row = rows.first
    body = normalize_text(row["RowTitle"])

    if body.nil? || row["RowDetail"] || row["Next"] || row["Presented"]
      raise MigrationError, "#{resource_name} introduction row must be plain text only."
    end

    {
      "displayTitle" => title,
      "body" => body
    }
  end

  def build_move_group(section, resource_name:, group_id:, expected_title:)
    actual_title = normalize_text(section["SectionTitle"])
    unless actual_title == expected_title
      raise MigrationError,
            "#{resource_name} expected top-level section #{expected_title.inspect} for #{group_id}, found #{actual_title.inspect}."
    end

    rows = fetch_rows(section, context: "#{resource_name} > #{expected_title}")

    {
      "id" => group_id,
      "displayTitle" => actual_title,
      "entries" => convert_rows_to_entries(
        rows,
        section_title: nil,
        path: [resource_name, expected_title]
      )
    }
  end

  def convert_rows_to_entries(rows, section_title:, path:)
    allocator = StableIDAllocator.new

    Array(rows).map.with_index do |row, index|
      convert_row(
        row,
        section_title: section_title,
        allocator: allocator,
        path: path + ["row##{index + 1}"]
      )
    end
  end

  def convert_sections_to_entries(sections, path:)
    allocator = StableIDAllocator.new
    entries = []

    Array(sections).each_with_index do |section, section_index|
      section_title = normalize_text(section["SectionTitle"])
      rows = fetch_rows(section, context: format_path(path + ["section##{section_index + 1}"]))

      rows.each_with_index do |row, row_index|
        entries << convert_row(
          row,
          section_title: section_title,
          allocator: allocator,
          path: path + ["section##{section_index + 1}", "row##{row_index + 1}"]
        )
      end
    end

    raise MigrationError, "#{format_path(path)} resolved to an empty children list." if entries.empty?

    entries
  end

  def convert_row(row, section_title:, allocator:, path:)
    display_name = visible_row_title(row)
    raise MigrationError, "#{format_path(path)} has no visible row title." if display_name.nil?

    entry = {
      "id" => allocator.next_id(display_name),
      "displayName" => display_name
    }

    if row["Next"]
      sections = fetch_next_sections(row, context: format_path(path + [display_name]))
      page = convert_page(
        sections: sections,
        fallback_display_name: display_name,
        path: path + [display_name]
      )
      entry.merge!(page)
    else
      entry["detail"] = build_standalone_row_detail(
        row: row,
        section_title: section_title,
        fallback_display_name: display_name,
        path: path + [display_name]
      )
    end

    entry
  end

  def convert_page(sections:, fallback_display_name:, path:)
    if page_contains_next_rows?(sections) || page_requires_inline_children?(sections)
      {
        "children" => convert_sections_to_entries(sections, path: path)
      }
    else
      {
        "detail" => build_page_detail(
          sections: sections,
          fallback_display_name: fallback_display_name,
          path: path
        )
      }
    end
  end

  def build_standalone_row_detail(row:, section_title:, fallback_display_name:, path:)
    builder = MoveDetailBuilder.new(fallback_display_name)

    if row["Presented"]
      builder.media_entries << build_media(row, path: path)
    elsif row["RowDetail"]
      apply_detail_value(
        builder,
        section_title: section_title,
        row_title: normalize_text(row["RowTitle"]),
        row_detail: normalize_text(row["RowDetail"]),
        path: path
      )
    elsif plain_text = normalize_text(row["RowTitle"])
      if section_title && !section_title.empty?
        if note_group_title?(section_title)
          builder.add_note_group(section_title, [plain_text])
        else
          builder.add_note_group(section_title, [plain_text])
        end
      else
        builder.add_note_group(fallback_display_name, [plain_text])
      end
    else
      raise MigrationError, "#{format_path(path)} is not a supported standalone row shape."
    end

    builder.to_h
  end

  def build_page_detail(sections:, fallback_display_name:, path:)
    builder = MoveDetailBuilder.new(fallback_display_name)

    Array(sections).each_with_index do |section, section_index|
      section_title = normalize_text(section["SectionTitle"])
      rows = fetch_rows(section, context: format_path(path + ["section##{section_index + 1}"]))

      if section_title.nil?
        process_untitled_detail_rows(
          builder,
          rows: rows,
          fallback_display_name: fallback_display_name,
          path: path + ["section##{section_index + 1}"]
        )
      elsif section_title == "ゲージ増加量"
        process_exact_labeled_section(
          builder,
          key: :meter_gain,
          rows: rows,
          path: path + [section_title]
        )
      elsif section_title == "ヒット&ガード硬直時間差"
        process_exact_labeled_section(
          builder,
          key: :frame_advantage,
          rows: rows,
          path: path + [section_title]
        )
      elsif note_group_title?(section_title)
        if rows.all? { |row| row["RowTitle"] && !row["RowDetail"] && !row["Next"] && !row["Presented"] }
          builder.add_note_group(section_title, extract_plain_entries(rows, path: path + [section_title]))
        else
          process_custom_detail_section(
            builder,
            section_title: section_title,
            rows: rows,
            path: path + [section_title]
          )
        end
      else
        process_custom_detail_section(
          builder,
          section_title: section_title,
          rows: rows,
          path: path + [section_title]
        )
      end
    end

    builder.to_h
  end

  def process_untitled_detail_rows(builder, rows:, fallback_display_name:, path:)
    note_entries = []

    Array(rows).each_with_index do |row, index|
      row_path = path + ["row##{index + 1}"]

      if row["Presented"]
        builder.media_entries << build_media(row, path: row_path)
      elsif row["RowDetail"]
        row_title = normalize_text(row["RowTitle"])
        row_detail = normalize_text(row["RowDetail"])
        apply_detail_value(builder, section_title: nil, row_title: row_title, row_detail: row_detail, path: row_path)
      elsif plain_text = normalize_text(row["RowTitle"])
        note_entries << plain_text
      else
        raise MigrationError, "#{format_path(row_path)} is not a supported untitled leaf row shape."
      end
    end

    builder.add_note_group(fallback_display_name, note_entries) unless note_entries.empty?
  end

  def process_exact_labeled_section(builder, key:, rows:, path:)
    Array(rows).each_with_index do |row, index|
      row_title = normalize_text(row["RowTitle"])
      row_detail = normalize_text(row["RowDetail"])

      unless row_title && row_detail && !row["Next"] && !row["Presented"]
        raise MigrationError, "#{format_path(path + ["row##{index + 1}"])} must be a simple key/value row."
      end

      if key == :meter_gain
        builder.add_meter_gain(row_title, row_detail)
      else
        builder.add_frame_advantage(row_title, row_detail)
      end
    end
  end

  def process_custom_detail_section(builder, section_title:, rows:, path:)
    if rows.all? { |row| row["RowDetail"] && !row["Next"] && !row["Presented"] }
      Array(rows).each_with_index do |row, index|
        label = compose_label(section_title, normalize_text(row["RowTitle"]))
        value = normalize_text(row["RowDetail"])

        raise MigrationError, "#{format_path(path + ["row##{index + 1}"])} has an empty custom stat value." if value.nil?

        builder.add_stat(label, value)
      end
    elsif rows.all? { |row| normalize_text(row["RowTitle"]) && !row["RowDetail"] && !row["Next"] && !row["Presented"] }
      builder.add_note_group(section_title, rows.map { |row| normalize_text(row["RowTitle"]) })
    else
      raise MigrationError,
            "#{format_path(path)} mixes incompatible row shapes inside custom section #{section_title.inspect}."
    end
  end

  def apply_detail_value(builder, section_title:, row_title:, row_detail:, path:)
    raise MigrationError, "#{format_path(path)} has an empty row title." if row_title.nil?
    raise MigrationError, "#{format_path(path)} has an empty row detail for #{row_title.inspect}." if row_detail.nil?

    if section_title.nil?
      field_name = STANDARD_FIELD_MAP[row_title]

      if field_name
        if builder.standard_field_assigned?(field_name)
          builder.add_stat(row_title, row_detail)
        else
          builder.assign_standard_field(field_name, row_detail, path: path + [row_title])
        end
      else
        builder.add_stat(row_title, row_detail)
      end
    elsif section_title == "ゲージ増加量"
      builder.add_meter_gain(row_title, row_detail)
    elsif section_title == "ヒット&ガード硬直時間差"
      builder.add_frame_advantage(row_title, row_detail)
    elsif note_group_title?(section_title)
      builder.add_note_group(section_title, ["#{row_title}: #{row_detail}"])
    else
      builder.add_stat(compose_label(section_title, row_title), row_detail)
    end
  end

  def build_media(row, path:)
    presented = row["Presented"]
    display_label = visible_row_title(row) || "モーション"

    unless normalize_text(presented["ViewController"]) == "FramesPlayerViewController"
      raise MigrationError,
            "#{format_path(path)} has unsupported Presented.ViewController #{presented["ViewController"].inspect}."
    end

    {
      "kind" => "motion_player",
      "displayLabel" => display_label,
      "skillName" => required_text(presented["SkillName"], path: path + ["Presented.SkillName"]),
      "characterCode" => required_text(presented["CharacterCode"], path: path + ["Presented.CharacterCode"]),
      "skillCode" => required_text(presented["SkillCode"], path: path + ["Presented.SkillCode"])
    }
  end

  def extract_plain_entries(rows, path:)
    Array(rows).each_with_index.map do |row, index|
      unless row["RowTitle"] && !row["RowDetail"] && !row["Next"] && !row["Presented"]
        raise MigrationError, "#{format_path(path + ["row##{index + 1}"])} must contain plain text rows only."
      end

      normalize_text(row["RowTitle"])
    end
  end

  def page_contains_next_rows?(sections)
    Array(sections).any? do |section|
      Array(section["Rows"]).any? { |row| row["Next"] }
    end
  end

  def page_requires_inline_children?(sections)
    section_titles = []

    Array(sections).any? do |section|
      title = normalize_text(section["SectionTitle"])
      section_titles << title if title

      rows = Array(section["Rows"])

      untitled_standard_titles = if title.nil?
        rows.filter_map do |row|
          next unless row["RowDetail"]

          row_title = normalize_text(row["RowTitle"])
          row_title if STANDARD_FIELD_MAP.key?(row_title)
        end
      else
        []
      end

      untitled_standard_titles.uniq.length != untitled_standard_titles.length
    end || section_titles.uniq.length != section_titles.length
  end

  def fetch_rows(section, context:)
    rows = Array(section["Rows"])
    raise MigrationError, "#{context} has no Rows." if rows.empty?

    rows
  end

  def fetch_next_sections(row, context:)
    sections = row.dig("Next", "Sections")
    sections = Array(sections)

    raise MigrationError, "#{context} has Next without Sections." if sections.empty?

    sections
  end

  def compose_label(section_title, row_title)
    return section_title if row_title.nil? || row_title.empty?

    "#{section_title} #{row_title}"
  end

  def visible_row_title(row)
    normalize_text(row["RowTitle"]) || normalize_text(row.dig("Presented", "SkillName"))
  end

  def required_text(value, path:)
    text = normalize_text(value)
    raise MigrationError, "#{format_path(path)} must not be empty." if text.nil?

    text
  end

  def note_group_title?(title)
    NOTE_GROUP_TITLES.include?(title)
  end

  def normalize_character_id(value)
    normalized = normalize_text(value)
    raise MigrationError, "Character id source must not be empty." if normalized.nil?

    normalized
      .unicode_normalize(:nfkc)
      .downcase
      .gsub(/[^a-z0-9]+/, "_")
      .gsub(/\A_+|_+\z/, "")
  end

  def normalize_text(value)
    return nil if value.nil?

    text = value.to_s.strip
    return nil if text.empty?

    text
  end

  def load_yaml_document(path)
    YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  rescue Psych::SyntaxError => error
    raise MigrationError, "Failed to parse YAML at #{relative_path(path)}: #{error.message}"
  end

  def write_yaml(path, document)
    yaml = Psych.dump(document, line_width: -1).sub(/\A---\n/, "")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, yaml)
  end

  def verify!(roster:, output_paths:, input_dir:, output_dir:)
    raise MigrationError, "Expected 19 characters in Characters.yml but found #{roster.length}." unless roster.length == 19

    missing_input_files = roster.reject do |entry|
      File.exist?(File.join(input_dir, entry.fetch("resourceName")))
    end
    unless missing_input_files.empty?
      missing = missing_input_files.map { |entry| entry.fetch("resourceName") }.join(", ")
      raise MigrationError, "Missing source character YAML files: #{missing}."
    end

    unless output_paths.length == roster.length
      raise MigrationError, "Expected #{roster.length} output files but wrote #{output_paths.length}."
    end

    missing_outputs = output_paths.reject { |path| File.exist?(path) }
    unless missing_outputs.empty?
      raise MigrationError, "Missing migrated output files: #{missing_outputs.map { |path| relative_path(path) }.join(", ")}."
    end

    yaml_count = Dir.glob(File.join(output_dir, "*.yml")).length
    unless yaml_count == roster.length
      raise MigrationError,
            "Expected #{roster.length} migrated YAML files in #{relative_path(output_dir)} but found #{yaml_count}."
    end

    output_paths.each do |path|
      document = load_yaml_document(path)
      validate_structured_document(document, path: path)
    end
  end

  def validate_structured_document(document, path:)
    unless document.is_a?(Hash)
      raise MigrationError, "Structured output #{relative_path(path)} must decode to a mapping."
    end

    keys = document.keys
    unless keys == ["character", "introduction", "moveGroups"]
      raise MigrationError,
            "Structured output #{relative_path(path)} must contain only character/introduction/moveGroups in order."
    end

    move_groups = Array(document["moveGroups"])
    expected_ids = GROUP_DEFINITIONS.map(&:first)
    actual_ids = move_groups.map { |group| group["id"] }

    unless actual_ids == expected_ids
      raise MigrationError,
            "Structured output #{relative_path(path)} has moveGroups #{actual_ids.inspect}, expected #{expected_ids.inspect}."
    end
  end

  def relative_path(path)
    Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
  end

  def format_path(parts)
    Array(parts).compact.reject(&:empty?).join(" > ")
  end

  class StableIDAllocator
    def initialize
      @counts = Hash.new(0)
    end

    def next_id(source)
      base = stable_token(source)
      @counts[base] += 1
      return base if @counts[base] == 1

      "#{base}_#{@counts[base]}"
    end

    private

    def stable_token(source)
      text = source.to_s.unicode_normalize(:nfkc).downcase
      ascii = text
              .gsub(/[[:space:][:punct:]]+/, "_")
              .gsub(/[^a-z0-9_]/, "")
              .gsub(/_+/, "_")
              .gsub(/\A_+|_+\z/, "")

      return ascii unless ascii.empty?

      "item_#{Digest::SHA1.hexdigest(source.to_s)[0, 10]}"
    end
  end

  class MoveDetailBuilder
    attr_reader :media_entries

    def initialize(fallback_display_name)
      @display_name = fallback_display_name
      @assigned_standard_fields = {}
      @standard_fields = {}
      @meter_gain = []
      @frame_advantage = []
      @stats = []
      @note_groups = []
      @note_group_ids = StableIDAllocator.new
      @labeled_value_ids = {
        meter_gain: StableIDAllocator.new,
        frame_advantage: StableIDAllocator.new,
        stats: StableIDAllocator.new
      }
      @media_entries = []
    end

    def assign_standard_field(field_name, value, path:)
      if field_name == "displayName"
        @assigned_standard_fields[field_name] = true
        @display_name = value
        return
      end

      if @standard_fields.key?(field_name)
        raise MigrationError, "#{Array(path).join(" > ")} sets #{field_name} more than once."
      end

      @standard_fields[field_name] = value
      @assigned_standard_fields[field_name] = true
    end

    def standard_field_assigned?(field_name)
      @assigned_standard_fields.fetch(field_name, false)
    end

    def add_meter_gain(label, value)
      @meter_gain << labeled_value(:meter_gain, label, value)
    end

    def add_frame_advantage(label, value)
      @frame_advantage << labeled_value(:frame_advantage, label, value)
    end

    def add_stat(label, value)
      @stats << labeled_value(:stats, label, value)
    end

    def add_note_group(display_title, entries)
      normalized_entries = Array(entries).filter_map do |entry|
        text = entry.to_s.strip
        text.empty? ? nil : text
      end
      return if normalized_entries.empty?

      @note_groups << {
        "id" => @note_group_ids.next_id(display_title),
        "displayTitle" => display_title,
        "entries" => normalized_entries
      }
    end

    def to_h
      raise MigrationError, "MoveDetail.displayName must not be empty." if @display_name.nil? || @display_name.empty?

      detail = { "displayName" => @display_name }
      @standard_fields.each { |key, value| detail[key] = value }
      detail["meterGain"] = @meter_gain unless @meter_gain.empty?
      detail["frameAdvantage"] = @frame_advantage unless @frame_advantage.empty?
      detail["stats"] = @stats unless @stats.empty?
      detail["noteGroups"] = @note_groups unless @note_groups.empty?
      if @media_entries.length == 1
        detail["media"] = @media_entries.first
      elsif @media_entries.length > 1
        detail["mediaEntries"] = @media_entries
      end
      detail
    end

    private

    def labeled_value(kind, label, value)
      {
        "id" => @labeled_value_ids.fetch(kind).next_id(label),
        "label" => label,
        "value" => value
      }
    end
  end
end

options = {
  input_dir: CharacterYAMLStructuredMigrator::DEFAULT_INPUT_DIR,
  output_dir: CharacterYAMLStructuredMigrator::DEFAULT_OUTPUT_DIR
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/character_yaml_phase4_structured_migration.rb [options]"

  parser.on("--input-dir PATH", "Read legacy YAML files from PATH.") do |path|
    options[:input_dir] = File.expand_path(path, Dir.pwd)
  end

  parser.on("--output-dir PATH", "Write structured YAML files into PATH.") do |path|
    options[:output_dir] = File.expand_path(path, Dir.pwd)
  end
end.parse!

begin
  report = CharacterYAMLStructuredMigrator.new.migrate(
    input_dir: options[:input_dir],
    output_dir: options[:output_dir]
  )

  puts "Wrote #{report.fetch("characterCount")} structured YAML files to #{report.fetch("outputDirectory")}"
  report.fetch("files").each do |file_path|
    puts "- #{file_path}"
  end
rescue CharacterYAMLStructuredMigrator::MigrationError => error
  warn error.message
  exit 1
end
