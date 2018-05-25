require 'sinatra'
require 'rest-client'
require 'json'
require 'slack-notifier'
require 'jenkins_api_client'

$stdout.sync = true

get '/' do
  "This is a thing"
end

post '/' do

  # Verify all environment variables are set
  return [403, "No slack token setup"] unless slack_token = ENV['SLACK_TOKEN']
  return [403, "No jenkins url setup"] unless jenkins_url= ENV['JENKINS_URL']
  return [403, "No jenkins token setup"] unless jenkins_token= ENV['JENKINS_TOKEN']

  # Verify slack token matches environment variable
  return [401, "No authorized for this command"] unless slack_token == params['token']

  jenkins_no_token= ENV['JENKINS_NOTOKEN_URL']
  a_ok_note=""
  # Split command text
  text_parts = params['text'].split(' ')
  puts text_parts
  # Split command text - job name
  job_name = text_parts[0]
  command = text_parts[1]
  commandValue = text_parts[2]
  flag="on"
  
  # Split command text - parameters
  parameters = []
  if text_parts.size > 1
    all_params = text_parts[1..-1]
    all_params.each do |p|
      p_thing = p.split('=')
      parameters << { :name => p_thing[0], :value => p_thing[1] }
    end
  end

  # Jenkins url
  jenkins_job_url = "#{jenkins_url}/job/#{job_name}"
  jenkins_notoken_job_url = "#{jenkins_no_token}/job/#{job_name}"
  
  # Get Jenkins client
  @client=JenkinsApi::Client.new(:server_url =>"#{jenkins_url}",:username => 'medu', :password => 'password')
  #@client = JenkinsApi::Client.new(YAML.load_file(File.expand_path("~/.jenkins-slack-command/login.yml", __FILE__)))

  slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
  if slack_webhook_url
    notifier = Slack::Notifier.new slack_webhook_url do
    middleware :format_message, :format_attachments
    end
  end
  
  
  
  # Condition start
  # Print list of command and usage
  if text_parts[0] == "-help" || text_parts[1] == "-help" || text_parts[2] == "-help" || text_parts.size <= 0
    puts 'Result'
    teamList=["MU","Chelsea","Liver","ManCity","Totenham","Arsenal","PSG","Juve","Napoli","Inter","Roma","Real","Barca","Atletico","Bayern","Dortmund","European Classic","World Classic"]
    team = teamList[rand(teamList.length)]
    a_ok_note = {
      text: "*#{team}*\n,
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
    flag="off"
  end
  
end
