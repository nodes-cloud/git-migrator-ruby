#!/usr/bin/ruby2.3

require 'json'
require 'tty-prompt'
require 'colorize'
require 'inquirer'

@token = "<git.nodescloud.com token>"

def get_projects
  data = `curl "https://git.nodescloud.com/api/v3/projects/all?page=1&per_page=200&private_token=#{@token}"`
  @projects = JSON.parse(data)
end

def archive_project(project_id)
  puts "Archiving project with id: #{project_id}"
  `curl --request POST "https://git.nodescloud.com/api/v3/projects/#{project_id}/archive?private_token=#{@token}"`
end

# Stupid Github is stupid
def create_project(name, type)
end

def run(source_repo = nil, dest_repo = nil, project_name, project_id)

  begin
    if source_repo.nil?
      source_repo = Ask.input 'Please input source repo'
    else
      puts "Starting clone from: #{source_repo}".colorize(:light_green)
    end
  rescue SystemExit, Interrupt
    exit
  end

  unless system("git ls-remote #{source_repo} HEAD")
    puts 'Access to source repo failed'.colorize(:red)
    exit
  end

  begin
    if dest_repo.nil?
      dest_repo = Ask.input 'Please input destination repo'
    end
  rescue SystemExit, Interrupt
    exit
  end

  unless system("git ls-remote #{dest_repo} HEAD")
    puts 'Access to destination repo failed'.colorize(:red)
    exit
  end

  Dir.chdir('/tmp/')

  if File.exist? ("/tmp/#{source_repo}")
    Dir.rmdir("/tmp/#{source_repo}")
  end

  `git clone --mirror #{source_repo}`

  Dir.chdir(source_repo.split('/')[-1])

  `git push --no-verify --mirror #{dest_repo}`

  puts 'Repo migrated!'

  archive_project(project_id)

  File.open('/home/sikr/moved_projects.txt', 'a') do |f|
    f.puts("#{project_name}: #{dest_repo}")
  end

end
get_projects

prompt = TTY::Prompt.new

begin
  @selected_project = prompt.select("Choose Project", per_page: 30) do |menu|
    @projects.each do |project|
      menu.choice "#{project['name']} - #{project['namespace']['name']}", project['id']
    end
  end
rescue SystemExit, Interrupt
  exit
end

@projects.each do |project|
  if project['id'] == @selected_project
    run(project['ssh_url_to_repo'], nil, project['name'], project['id'])
  end
end


