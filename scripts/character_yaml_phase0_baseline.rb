#!/usr/bin/env ruby

require "json"
require "optparse"
require "pathname"
require "set"
require "time"
require "yaml"

class CharacterYAMLBaselineAnalyzer
  ROOT = File.expand_path("..", __dir__)
  DATA_DIR = File.join(ROOT, "RedBlocking", "Resources", "CharacterData")
  DEFAULT_MARKDOWN_PATH = File.join(ROOT, "docs", "CHARACTER_YAML_PHASE0_BASELINE.md")
  DEFAULT_JSON_PATH = File.join(ROOT, "docs", "character_yaml_phase0_baseline.json")

  EXPECTED_GAMEPLAY_TITLES = [
    "【空中通常技】",
    "【地上通常技】",
    "【特殊入力技】",
    "【必殺技】",
    "【スーパーアーツ】"
  ].freeze

  STANDARD_DETAIL_SECTION_TITLES = Set.new([
    "ゲージ増加量",
    "ヒット&ガード硬直時間差",
    "補足",
    "通常",
    "EX",
    "効果",
    "投げ間合い",
    "硬直"
  ]).freeze

  VARIANT_INPUT_TITLES = Set.new([
    "共通",
    "小",
    "中",
    "大",
    "投げ版",
    "打撃版"
  ]).freeze

  MATCHUP_REFERENCE_TITLES = Set.new([
    "ダッドリー",
    "ヤン",
    "ネクロ",
    "トゥエルヴ",
    "ユン",
    "Q"
  ]).freeze

  CURRENT_UI_PARITY_CHECKLIST = [
    {
      "field" => "section_title",
      "description" => "List section header text from SectionTitle when the title is non-empty.",
      "source" => "RedBlocking/CharacterMove/Views/MoveBrowserView.swift"
    },
    {
      "field" => "row_title",
      "description" => "Primary row text resolved with the same fallback rules as MoveBrowserModel.title(for:).",
      "source" => "RedBlocking/CharacterMove/Models/MoveBrowserModel.swift"
    },
    {
      "field" => "row_subtitle",
      "description" => "Secondary row text from RowDetail for branch rows, or Presented.SkillName when the player entry title differs.",
      "source" => "RedBlocking/CharacterMove/Models/MoveBrowserModel.swift"
    },
    {
      "field" => "row_kind",
      "description" => "Visible row style: next, motion_player, detail, or supplementary.",
      "source" => "RedBlocking/CharacterMove/Views/MoveBrowserView.swift"
    },
    {
      "field" => "navigation_title",
      "description" => "Root page title comes from the selected character; pushed move pages and motion player pages use the resolved row title.",
      "source" => "RedBlocking/CharacterMove/Models/AppNavigationModel.swift"
    },
    {
      "field" => "navigation_depth",
      "description" => "Number of Next hops required before the destination page appears.",
      "source" => "RedBlocking/CharacterMove/Models/AppNavigationModel.swift"
    },
    {
      "field" => "action_entry",
      "description" => "Whether a row opens another move page, opens the motion player, or has no action.",
      "source" => "RedBlocking/CharacterMove/Models/MoveBrowserModel.swift"
    }
  ].freeze

  SPECIAL_PATTERN_DEFINITIONS = [
    {
      "id" => "deep_navigation_chains",
      "title" => "Deep navigation chains",
      "description" => "A move requires three or more Next hops before detail rows appear."
    },
    {
      "id" => "normal_ex_splits",
      "title" => "通常 / EX split blocks",
      "description" => "Supplementary note groups are split into separate 通常 and EX sections."
    },
    {
      "id" => "variant_input_or_strength_blocks",
      "title" => "Variant input / strength blocks",
      "description" => "Nested sections differentiate follow-up inputs, button strengths, or attack variants."
    },
    {
      "id" => "multi_stage_or_component_breakdowns",
      "title" => "Multi-stage / component breakdowns",
      "description" => "A move is decomposed into stages or hit components such as 1回目, 段目, or 部分."
    },
    {
      "id" => "specialized_stat_subsections",
      "title" => "Specialized stat subsections",
      "description" => "Custom stat buckets extend beyond the common ゲージ増加量 / ヒット&ガード硬直時間差 / 補足 trio."
    },
    {
      "id" => "state_specific_performance_blocks",
      "title" => "State-specific performance blocks",
      "description" => "A move embeds alternate stats for a special state such as 幻影陣中の性能."
    },
    {
      "id" => "nested_gameplay_group_reuse",
      "title" => "Nested gameplay group reuse",
      "description" => "A move reuses top-level gameplay section titles inside a deeper branch."
    },
    {
      "id" => "matchup_or_character_specific_blocks",
      "title" => "Matchup / character-specific blocks",
      "description" => "Notes or stats branch by target character or matchup-specific conditions."
    },
    {
      "id" => "unclassified_custom_sections",
      "title" => "Unclassified custom sections",
      "description" => "Custom nested section titles that do not fit the known buckets yet."
    }
  ].freeze

  def analyze
    character_paths = character_paths()
    character_reports = character_paths.map { |path| analyze_character(path) }
    verification = build_verification(character_reports)
    aggregate = build_aggregate(character_reports)

    {
      "generatedAt" => Time.now.utc.iso8601,
      "sourceDirectory" => relative_path(DATA_DIR),
      "verification" => verification,
      "aggregate" => aggregate,
      "parityChecklist" => CURRENT_UI_PARITY_CHECKLIST,
      "characters" => character_reports
    }
  end

  private

  def character_paths
    Dir.glob(File.join(DATA_DIR, "*.yml"))
      .reject { |path| File.basename(path) == "Characters.yml" }
      .sort
  end

  def analyze_character(path)
    sections = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
    report = {
      "characterId" => File.basename(path, ".yml"),
      "file" => relative_path(path),
      "topLevelSectionTitles" => [],
      "introductionSectionTitle" => nil,
      "gameplaySectionTitles" => [],
      "maxNavigationDepth" => 0,
      "rowKindCounts" => Hash.new(0),
      "actionEntryCounts" => Hash.new(0),
      "customNestedSectionTitles" => Hash.new { |hash, key| hash[key] = { "count" => 0, "examplePath" => nil } },
      "specialPatterns" => Hash.new { |hash, key| hash[key] = [] }
    }

    visit_sections(
      sections,
      report: report,
      branch_path: [],
      next_depth: 0
    )

    report["introductionSectionTitle"] = report["topLevelSectionTitles"].first
    report["gameplaySectionTitles"] = report["topLevelSectionTitles"].drop(1)
    report["rowKindCounts"] = report["rowKindCounts"].sort.to_h
    report["actionEntryCounts"] = report["actionEntryCounts"].sort.to_h
    report["customNestedSectionTitles"] = report["customNestedSectionTitles"]
      .sort_by { |title, data| [title, data["examplePath"]] }
      .to_h
    report["specialPatterns"] = SPECIAL_PATTERN_DEFINITIONS.map do |definition|
      occurrences = report["specialPatterns"][definition["id"]]
      {
        "id" => definition["id"],
        "title" => definition["title"],
        "description" => definition["description"],
        "count" => occurrences.length,
        "examples" => occurrences.first(5)
      }
    end.select { |entry| entry["count"].positive? }

    report
  end

  def visit_sections(sections, report:, branch_path:, next_depth:)
    sections.each do |section|
      section_title = normalize_title(section["SectionTitle"])

      if next_depth.zero?
        report["topLevelSectionTitles"] << section_title
      else
        classify_nested_section(section_title, report: report, branch_path: branch_path, next_depth: next_depth)
      end

      section_path = branch_path.dup
      section_path << section_title if section_title

      Array(section["Rows"]).each do |row|
        row_title = visible_row_title(row)
        row_kind = row_kind(row)
        report["rowKindCounts"][row_kind] += 1

        action_kind = action_kind(row)
        report["actionEntryCounts"][action_kind] += 1 if action_kind

        row_path = section_path.dup
        row_path << row_title if row_title

        if row["Next"]
          child_depth = next_depth + 1
          report["maxNavigationDepth"] = [report["maxNavigationDepth"], child_depth].max

          if child_depth >= 3
            add_special_pattern(
              report,
              "deep_navigation_chains",
              row_path,
              next_depth: child_depth
            )
          end

          visit_sections(
            Array(row.dig("Next", "Sections")),
            report: report,
            branch_path: row_path,
            next_depth: child_depth
          )
        end
      end
    end
  end

  def classify_nested_section(title, report:, branch_path:, next_depth:)
    return unless title

    if custom_nested_title?(title)
      custom_title_entry = report["customNestedSectionTitles"][title]
      custom_title_entry["count"] += 1
      custom_title_entry["examplePath"] ||= render_path(branch_path + [title])
    end

    pattern_id =
      if EXPECTED_GAMEPLAY_TITLES.include?(title)
        "nested_gameplay_group_reuse"
      elsif title == "幻影陣中の性能"
        "state_specific_performance_blocks"
      elsif %w[通常 EX].include?(title)
        "normal_ex_splits"
      elsif variant_input_or_strength_title?(title)
        "variant_input_or_strength_blocks"
      elsif matchup_or_character_specific_title?(title)
        "matchup_or_character_specific_blocks"
      elsif multi_stage_or_component_title?(title)
        "multi_stage_or_component_breakdowns"
      elsif specialized_stat_title?(title)
        "specialized_stat_subsections"
      elsif custom_nested_title?(title)
        "unclassified_custom_sections"
      end

    return unless pattern_id

    add_special_pattern(
      report,
      pattern_id,
      branch_path + [title],
      next_depth: next_depth
    )
  end

  def add_special_pattern(report, pattern_id, path, next_depth:)
    rendered_path = render_path(path)
    occurrences = report["specialPatterns"][pattern_id]
    return if occurrences.any? { |entry| entry["path"] == rendered_path }

    occurrences << {
      "path" => rendered_path,
      "navigationDepth" => next_depth
    }
  end

  def build_verification(character_reports)
    failures = []

    if character_reports.length != 19
      failures << "Expected 19 character YAML files but found #{character_reports.length}."
    end

    character_reports.each do |report|
      titles = report["topLevelSectionTitles"]

      if titles.length != 6
        failures << "#{report["characterId"]} should expose 6 top-level sections but has #{titles.length}."
      end

      gameplay_titles = report["gameplaySectionTitles"]
      unless gameplay_titles == EXPECTED_GAMEPLAY_TITLES
        failures << "#{report["characterId"]} gameplay sections differ from the expected fixed order."
      end
    end

    {
      "passed" => failures.empty?,
      "characterCount" => character_reports.length,
      "expectedGameplaySectionTitles" => EXPECTED_GAMEPLAY_TITLES,
      "failures" => failures
    }
  end

  def build_aggregate(character_reports)
    aggregate_row_kinds = Hash.new(0)
    aggregate_actions = Hash.new(0)
    global_custom_titles = Hash.new { |hash, key| hash[key] = Set.new }
    global_patterns = Hash.new { |hash, key| hash[key] = [] }

    character_reports.each do |report|
      report["rowKindCounts"].each do |kind, count|
        aggregate_row_kinds[kind] += count
      end

      report["actionEntryCounts"].each do |kind, count|
        aggregate_actions[kind] += count
      end

      report["customNestedSectionTitles"].each_key do |title|
        global_custom_titles[title] << report["characterId"]
      end

      report["specialPatterns"].each do |pattern|
        global_patterns[pattern["id"]] << {
          "characterId" => report["characterId"],
          "count" => pattern["count"],
          "examples" => pattern["examples"]
        }
      end
    end

    deepest_character = character_reports.max_by { |report| report["maxNavigationDepth"] }

    {
      "fixedGameplaySectionTitlesConfirmedForAllCharacters" => character_reports.all? do |report|
        report["gameplaySectionTitles"] == EXPECTED_GAMEPLAY_TITLES
      end,
      "deepestNavigation" => {
        "characterId" => deepest_character["characterId"],
        "depth" => deepest_character["maxNavigationDepth"]
      },
      "rowKindTotals" => aggregate_row_kinds.sort.to_h,
      "actionEntryTotals" => aggregate_actions.sort.to_h,
      "customNestedSectionTitleCatalog" => global_custom_titles
        .sort_by { |title, _characters| title }
        .map do |title, characters|
          {
            "title" => title,
            "characters" => characters.to_a.sort
          }
        end,
      "specialPatterns" => SPECIAL_PATTERN_DEFINITIONS.map do |definition|
        character_entries = global_patterns[definition["id"]]
        next if character_entries.empty?

        {
          "id" => definition["id"],
          "title" => definition["title"],
          "description" => definition["description"],
          "characterCount" => character_entries.length,
          "characters" => character_entries
            .sort_by { |entry| entry["characterId"] }
            .map { |entry| entry["characterId"] },
          "examples" => character_entries
            .sort_by { |entry| entry["characterId"] }
            .filter_map do |entry|
              example = entry["examples"].first
              example&.merge("characterId" => entry["characterId"])
            end
            .first(6)
        }
      end.compact
    }
  end

  def visible_row_title(row)
    title = normalize_title(row["RowTitle"])
    return title if title

    normalize_title(row.dig("Presented", "SkillName")) || "Unknown Move"
  end

  def row_kind(row)
    return "next" if row["Next"]
    return "motion_player" if motion_player_entry?(row)
    return "detail" if row["RowDetail"]

    "supplementary"
  end

  def action_kind(row)
    return "open_next" if row["Next"]
    return "open_motion_player" if motion_player_entry?(row)

    nil
  end

  def motion_player_entry?(row)
    row.dig("Presented", "ViewController") == "FramesPlayerViewController"
  end

  def normalize_title(value)
    return nil unless value

    title = value.to_s.strip
    return nil if title.empty?

    title
  end

  def custom_nested_title?(title)
    return false unless title
    return false if STANDARD_DETAIL_SECTION_TITLES.include?(title)
    return false if EXPECTED_GAMEPLAY_TITLES.include?(title)

    true
  end

  def variant_input_or_strength_title?(title)
    title.start_with?("追加入力") || VARIANT_INPUT_TITLES.include?(title)
  end

  def matchup_or_character_specific_title?(title)
    MATCHUP_REFERENCE_TITLES.include?(title) || title.include?("キャラ")
  end

  def multi_stage_or_component_title?(title)
    return true if title.match?(/\A\d+回目/)
    return true if title.match?(/\A[0-9・]+段目/)
    return true if title.start_with?("最初の", "ラストの")
    return true if title.start_with?("連打による追加")
    return true if title.include?("部分")
    return true if title.end_with?("蹴り上げ", "昇龍拳", "サマー")
    return true if title.start_with?("上段", "下段")

    false
  end

  def specialized_stat_title?(title)
    return false if STANDARD_DETAIL_SECTION_TITLES.include?(title)

    return true if title.start_with?("ヒット&ガード硬直時間差(")
    return true if title.end_with?("ゲージ増加量")
    return true if title.end_with?("ヒット&ガード硬直時間差")
    return true if %w[投げ間合い 効果 硬直 攻撃力 ケズリ スタン値 発生 持続].include?(title)

    false
  end

  def render_path(parts)
    parts.compact.map { |part| part.gsub(/\s+/, " ").strip }.reject(&:empty?).join(" > ")
  end

  def relative_path(path)
    Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
  end
end

class CharacterYAMLBaselineMarkdownRenderer
  def initialize(report)
    @report = report
  end

  def render
    lines = []
    lines << "# Character YAML Phase 0 Baseline"
    lines << ""
    lines << "Generated by `scripts/character_yaml_phase0_baseline.rb` on #{@report["generatedAt"]}."
    lines << ""
    lines << "## Verification Summary"
    lines << ""
    lines << "- Character YAML files scanned: #{@report.dig("verification", "characterCount")}"
    lines << "- Verification passed: #{@report.dig("verification", "passed")}"
    lines << "- Fixed gameplay section order: #{@report.dig("aggregate", "fixedGameplaySectionTitlesConfirmedForAllCharacters")}"
    lines << "- Deepest navigation chain: #{@report.dig("aggregate", "deepestNavigation", "characterId")} (depth #{@report.dig("aggregate", "deepestNavigation", "depth")})"
    lines << ""

    unless @report.dig("verification", "failures").empty?
      lines << "### Verification Failures"
      lines << ""
      @report.dig("verification", "failures").each do |failure|
        lines << "- #{failure}"
      end
      lines << ""
    end

    lines << "## Top-Level Section Titles"
    lines << ""
    lines << "All 19 character files share the same gameplay section order after the introduction section:"
    lines << ""
    lines << "```text"
    lines << @report.dig("verification", "expectedGameplaySectionTitles").join(" | ")
    lines << "```"
    lines << ""

    @report["characters"].each do |character|
      lines << "- `#{character["characterId"]}`: #{character["topLevelSectionTitles"].join(" | ")}"
    end
    lines << ""

    lines << "## Browser Parity Checklist"
    lines << ""
    @report["parityChecklist"].each do |entry|
      lines << "- `#{entry["field"]}`: #{entry["description"]} Source: `#{entry["source"]}`"
    end
    lines << ""

    lines << "## Special Nested Patterns"
    lines << ""
    @report.dig("aggregate", "specialPatterns").each do |pattern|
      lines << "### #{pattern["title"]}"
      lines << ""
      lines << "- Description: #{pattern["description"]}"
      lines << "- Characters: #{pattern["characters"].join(", ")}"
      pattern["examples"].each do |example|
        lines << "- Example: `#{example["characterId"]}` -> `#{example["path"]}` (depth #{example["navigationDepth"]})"
      end
      lines << ""
    end

    lines << "## Aggregate Row / Action Counts"
    lines << ""
    lines << "- Row kinds: #{format_counts(@report.dig("aggregate", "rowKindTotals"))}"
    lines << "- Action entries: #{format_counts(@report.dig("aggregate", "actionEntryTotals"))}"
    lines << ""

    lines << "## Custom Nested Section Title Catalog"
    lines << ""
    @report.dig("aggregate", "customNestedSectionTitleCatalog").each do |entry|
      lines << "- `#{entry["title"]}`: #{entry["characters"].join(", ")}"
    end
    lines << ""

    lines.join("\n")
  end

  private

  def format_counts(counts)
    counts.map { |key, value| "#{key}=#{value}" }.join(", ")
  end
end

options = {
  markdown_path: CharacterYAMLBaselineAnalyzer::DEFAULT_MARKDOWN_PATH,
  json_path: CharacterYAMLBaselineAnalyzer::DEFAULT_JSON_PATH
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/character_yaml_phase0_baseline.rb [options]"

  parser.on("--markdown PATH", "Write the Markdown report to PATH.") do |path|
    options[:markdown_path] = File.expand_path(path, Dir.pwd)
  end

  parser.on("--json PATH", "Write the JSON report to PATH.") do |path|
    options[:json_path] = File.expand_path(path, Dir.pwd)
  end
end.parse!

report = CharacterYAMLBaselineAnalyzer.new.analyze
markdown = CharacterYAMLBaselineMarkdownRenderer.new(report).render

File.write(options[:json_path], JSON.pretty_generate(report) + "\n")
File.write(options[:markdown_path], markdown)

puts "Wrote #{Pathname.new(options[:markdown_path]).relative_path_from(Pathname.new(Dir.pwd))}"
puts "Wrote #{Pathname.new(options[:json_path]).relative_path_from(Pathname.new(Dir.pwd))}"
puts "Verification passed: #{report.dig("verification", "passed")}"

exit(report.dig("verification", "passed") ? 0 : 1)
