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
  if text_parts[0] == "-help" || text_parts[1] == "-help"
    puts 'Help Page'
    a_ok_note = {
      text: "*List of commands*\n
      -build: Trigger a Jenkins job.\n
      -search: Search for Jenkins job by name.\n
      -get--configuration: Print job's configuration.\n",
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
  end
  
  case 
  # Make jenkins request
  when command=="-build"
     # Get next jenkins job build number
    resp = RestClient.get "#{jenkins_job_url}/api/json"
    resp_json = JSON.parse( resp.body )
    next_build_number = resp_json['nextBuildNumber']
    #json = JSON.generate( {:parameter => parameters} )
    #resp = RestClient.post "#{jenkins_job_url}/build?token=#{jenkins_token}", :json => json
    jobs_to_filter = "^#{job_name}.*"
    jobs = @client.job.list(jobs_to_filter)
    initial_jobs = @client.job.chain(jobs, 'success', ["all"])
    code = @client.job.build(initial_jobs[0])
    raise "Could not build the job specified" unless code == '201'
    # Build url
    build_url = "#{jenkins_job_url}/#{next_build_number}"
    notifier.ping "Started job '#{job_name}' - #{jenkins_notoken_job_url}/#{next_build_number}/"
    # End make jenkins request

    # Search for job by name
  when command=="-search"
    puts '#{jenkins_url}'
    #@client=JenkinsApi::Client.new(:server_url =>"#{jenkins_url}",:username => 'medu', :password => 'password')
    match_job=@client.job.list("^#{job_name}")
    puts match_job
    notifier.ping "List of matched jobs:#{match_job}"
   
  # Print job configuration
  when command=="-get--configuration"# View Bash/Shell command
    job_config=@client.job.get_config(job_name)
    a_ok_note = {
      text: "Configuration: *#{job_config}*",
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
    
  # Get Job Status
  when command=="-get--status"  
    job_status=@client.job.get_current_build_status("#{job_name}")
    #notifier.ping "Current build status of job"
    a_ok_note = {
      #text: "Job URL: #{jenkins_notoken_job_url}",
      text: "Jenkins job #{job_name} is *#{job_status}*",
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
  end
  
  # Update Job Name
  when command=="-rename"
    @client.job.rename("#{job_name}","#{commandValue}")
    a_ok_note = {
      text: "Your Jenkins job has been renamed to *#{commandValue}*",
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
  
  # Disable Job 
  when command=="-disable"
    @client.job.disable("#{job_name}")
    a_ok_note = {
      text: "Your Jenkins job *#{job_name}* has been disabled",
      color: "warning"
      }
    notifier.post attachments: [a_ok_note]
  
  # Enable Job 
  when command=="-enable" 
    @client.job.enable("#{job_name}")
    a_ok_note = {
      text: "Your Jenkins job *#{job_name}* has been enabled",
      color: "good"
      }
    notifier.post attachments: [a_ok_note]
  else
    a_ok_note = {
      text: "*Quit hacking my bot!*",
      color: "danger"
      }
    notifier.post attachments: [a_ok_note]
  end
  
  # Create Job 
  #if command == "-create"
  #  @client.job.create("#{job_name}")
  #  a_ok_note = {
  #    text: "This action is currently NOT supported",
  #    color: "danger"
  #    }
  #  notifier.post attachments: [a_ok_note]
  #end
  
end
