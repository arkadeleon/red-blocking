#!/usr/bin/env ruby

require "fileutils"
require "json"
require "optparse"
require "pathname"
require "yaml"

class CharacterYAMLLegacySnapshotExporter
  ROOT = File.expand_path("..", __dir__)
  DATA_DIR = File.join(ROOT, "RedBlocking", "Resources", "CharacterData")
  DEFAULT_OUTPUT_DIR = File.join(ROOT, "docs", "character_yaml_legacy_browser_snapshots")
  SCHEMA_VERSION = 1

  def export(output_dir: DEFAULT_OUTPUT_DIR)
    roster = load_roster
    FileUtils.mkdir_p(output_dir)

    snapshot_paths = roster.map do |entry|
      snapshot = build_snapshot(entry)
      output_path = File.join(output_dir, "#{snapshot.fetch("characterId")}.json")
      File.write(output_path, JSON.pretty_generate(snapshot) + "\n")
      output_path
    end

    verify!(roster: roster, snapshot_paths: snapshot_paths, output_dir: output_dir)

    {
      "characterCount" => roster.length,
      "outputDirectory" => relative_path(output_dir),
      "snapshots" => snapshot_paths.sort.map { |path| relative_path(path) }
    }
  end

  private

  def load_roster
    roster_path = File.join(DATA_DIR, "Characters.yml")
    rows = YAML.safe_load(File.read(roster_path), permitted_classes: [], aliases: false)

    Array(rows).map do |row|
      resource_name = row.fetch("Next")
      {
        "characterId" => File.basename(resource_name, ".yml"),
        "navigationTitle" => normalize_text(row.fetch("RowTitle")) || File.basename(resource_name, ".yml"),
        "resourceName" => resource_name
      }
    end
  end

  def build_snapshot(entry)
    path = File.join(DATA_DIR, entry.fetch("resourceName"))
    sections = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)

    {
      "schemaVersion" => SCHEMA_VERSION,
      "characterId" => entry.fetch("characterId"),
      "resourceName" => entry.fetch("resourceName"),
      "rootPage" => build_page(
        navigation_title: entry.fetch("navigationTitle"),
        sections: sections
      )
    }
  end

  def build_page(navigation_title:, sections:)
    {
      "navigationTitle" => navigation_title,
      "sections" => build_sections(sections)
    }
  end

  def build_sections(sections)
    Array(sections).map do |section|
      {
        "sectionTitle" => normalize_text(section["SectionTitle"]),
        "rows" => build_rows(section["Rows"])
      }
    end
  end

  def build_rows(rows)
    Array(rows).map do |row|
      title = visible_row_title(row)

      {
        "rowTitle" => title,
        "rowSubtitle" => visible_row_subtitle(row),
        "rowKind" => row_kind(row),
        "actionEntry" => action_entry(row, title: title),
        "children" => child_page(row, title: title)
      }
    end
  end

  def child_page(row, title:)
    return nil unless row["Next"]

    build_page(
      navigation_title: title,
      sections: row.dig("Next", "Sections")
    )
  end

  def action_entry(row, title:)
    if row["Next"]
      {
        "type" => "open_next",
        "navigationTitle" => title
      }
    elsif motion_player_entry?(row)
      presented = row.fetch("Presented")
      {
        "type" => "open_motion_player",
        "navigationTitle" => title,
        "skillName" => normalize_text(presented["SkillName"]),
        "characterCode" => normalize_text(presented["CharacterCode"]),
        "skillCode" => normalize_text(presented["SkillCode"]),
        "viewController" => normalize_text(presented["ViewController"])
      }
    else
      {
        "type" => "none"
      }
    end
  end

  def visible_row_title(row)
    normalize_text(row["RowTitle"]) ||
      normalize_text(row.dig("Presented", "SkillName")) ||
      "Unknown Move"
  end

  def visible_row_subtitle(row)
    return normalize_text(row["RowDetail"]) if row["Next"]

    return nil unless motion_player_entry?(row)

    title = visible_row_title(row)
    skill_name = normalize_text(row.dig("Presented", "SkillName"))
    return nil if title == skill_name

    skill_name
  end

  def row_kind(row)
    return "next" if row["Next"]
    return "motion_player" if motion_player_entry?(row)
    return "detail" if row["RowDetail"]

    "supplementary"
  end

  def motion_player_entry?(row)
    row.dig("Presented", "ViewController") == "FramesPlayerViewController"
  end

  def verify!(roster:, snapshot_paths:, output_dir:)
    raise "Expected 19 characters in Characters.yml but found #{roster.length}." unless roster.length == 19

    missing_resources = roster.reject do |entry|
      File.exist?(File.join(DATA_DIR, entry.fetch("resourceName")))
    end
    unless missing_resources.empty?
      names = missing_resources.map { |entry| entry.fetch("resourceName") }.join(", ")
      raise "Missing character YAML resources: #{names}."
    end

    unless snapshot_paths.length == roster.length
      raise "Expected #{roster.length} snapshot files but wrote #{snapshot_paths.length}."
    end

    duplicated_paths = snapshot_paths.group_by { |path| path }.select { |_path, paths| paths.length > 1 }
    unless duplicated_paths.empty?
      raise "Duplicate snapshot output paths detected: #{duplicated_paths.keys.join(", ")}."
    end

    missing_outputs = snapshot_paths.reject { |path| File.exist?(path) }
    unless missing_outputs.empty?
      raise "Snapshot files missing after export: #{missing_outputs.join(", ")}."
    end

    json_count = Dir.glob(File.join(output_dir, "*.json")).length
    unless json_count == roster.length
      raise "Expected #{roster.length} JSON snapshots in #{relative_path(output_dir)} but found #{json_count}."
    end
  end

  def normalize_text(value)
    return nil if value.nil?

    text = value.to_s.strip
    return nil if text.empty?

    text
  end

  def relative_path(path)
    Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
  end
end

options = {
  output_dir: CharacterYAMLLegacySnapshotExporter::DEFAULT_OUTPUT_DIR
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/character_yaml_phase1_legacy_snapshots.rb [options]"

  parser.on("--output-dir PATH", "Write snapshot files into PATH.") do |path|
    options[:output_dir] = File.expand_path(path, Dir.pwd)
  end
end.parse!

report = CharacterYAMLLegacySnapshotExporter.new.export(output_dir: options[:output_dir])

puts "Wrote #{report.fetch("characterCount")} snapshots to #{report.fetch("outputDirectory")}"
report.fetch("snapshots").each do |snapshot_path|
  puts "- #{snapshot_path}"
end
