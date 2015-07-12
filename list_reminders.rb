require 'rubygems' unless defined? Gem
require "./bundle/bundler/setup"

require 'json'
require "alfredo"

def read_json file_path
  JSON.parse File.open(file_path).read
end

def no_project
  Alfredo::Item.new(uid: 'empty', title: 'Project is not found')
end

wf = Alfredo::Workflow.new
cache_file_path = File.join wf.storage_path, 'reminder_cache.json'

if File.exists? cache_file_path
  reminder_lists = read_json(cache_file_path).select do |list|
    list['name'].downcase.start_with? ARGV.first.downcase
  end
else
  reminder_lists = []
end

if reminder_lists.empty?
  wf.items << no_project
else
  reminder_lists.first['todos'].each do |item|
    next if item['completed']
    title = '! ' * item['priority'] + item['title']
    wf.items << Alfredo::Item.new(uid: item['id'], title: title)
  end
end

wf.output!
