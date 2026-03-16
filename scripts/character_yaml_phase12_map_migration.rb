#!/usr/bin/env ruby
# Phase 12: Convert meterGain, frameAdvantage, and stats from
# array-of-labeled-values format to compact map format.

require "psych"

ROOT = File.expand_path("..", __dir__)
DATA_DIR = File.join(ROOT, "RedBlocking", "Resources", "CharacterData")

METER_GAIN_LABELS = {
  "空振り"    => "whiff",
  "ガード"    => "guard",
  "ヒット"    => "hit",
  "BL"        => "bl",
  "投げ成功時" => "throwSuccess",
  "空振り時"  => "onWhiff"
}.freeze

FRAME_ADVANTAGE_LABELS = {
  "ガード"  => "guard",
  "ヒット"  => "hit",
  "立ヒット" => "standingHit",
  "屈ヒット" => "crouchingHit"
}.freeze

def labeled_array_to_map(array, label_map)
  array.each_with_object({}) do |item, map|
    key = label_map.fetch(item["label"], item["label"])
    map[key] = item["value"]
  end
end

def stats_array_to_map(array)
  array.each_with_object({}) do |item, map|
    map[item["label"]] = item["value"]
  end
end

def transform_detail(detail)
  if detail["meterGain"].is_a?(Array)
    detail["meterGain"] = labeled_array_to_map(detail["meterGain"], METER_GAIN_LABELS)
  end
  if detail["frameAdvantage"].is_a?(Array)
    detail["frameAdvantage"] = labeled_array_to_map(detail["frameAdvantage"], FRAME_ADVANTAGE_LABELS)
  end
  if detail["stats"].is_a?(Array)
    detail["stats"] = stats_array_to_map(detail["stats"])
  end
end

def transform_entry(entry)
  transform_detail(entry["detail"]) if entry["detail"].is_a?(Hash)
  entry["children"]&.each { |child| transform_entry(child) }
end

migrated = 0

Dir.glob(File.join(DATA_DIR, "*.yml")).sort.each do |path|
  next if File.basename(path) == "Characters.yml"

  data = Psych.safe_load(File.read(path))

  data["moveGroups"]&.each do |group|
    group["entries"]&.each { |entry| transform_entry(entry) }
  end

  yaml = Psych.dump(data, line_width: -1).sub(/\A---\n/, "")
  File.write(path, yaml)
  puts "Migrated: #{File.basename(path)}"
  migrated += 1
end

puts "\nDone. Migrated #{migrated} files."
