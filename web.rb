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

  # Verify slack token matches environment variable
  return [401, "No authorized for this command"] unless slack_token == params['token']

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

  slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
  if slack_webhook_url
    notifier = Slack::Notifier.new slack_webhook_url do
    middleware :format_message, :format_attachments
    end
  end
  
  
  
  # Condition start
  if text_parts[0] == "-help" || text_parts[1] == "-help" || text_parts[2] == "-help" || text_parts.size <= 0
    puts 'Result'
    teamList=["MU","Chelsea","Liver","ManCity","Totenham","Arsenal","PSG","Juve","Napoli","Inter","Roma","Real","Barca","Atletico","Bayern","Dortmund","European Classic","World Classic"]
    team = teamList[rand(teamList.length)]
    a_ok_note = {
      text: "*#{team}*\n",
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
  end
  
end
