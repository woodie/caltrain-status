require "functions_framework"

FunctionsFramework.on_startup do
  require_relative "lib/status"
  set_global :status, Status.new(ENV["BEARER_TOKEN"])
end

FunctionsFramework.http "status" do |request|
  return [204, Status::OPTS_HEADERS, []] if request.options?

  message = global(:status).message(request.params["train"])
  return [500, {}, ["Something went wrong."]] if message.nil?

  [200, Status::RESP_HEADERS, [{message: message}.to_json]]
end
