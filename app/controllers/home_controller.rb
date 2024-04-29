class HomeController < ApplicationController
  def index
    @zip_code = '89129'

    ozone_info(@zip_code)
  end

  private

  def ozone_info(zip_code)
    require 'net/http'
    require 'json'

    @url = 'https://www.airnowapi.org'

    @distance = '25'
    @api_key = '6E07F514-2AF2-49EF-8826-2F65487CB1A2'

    @path = '/aq/observation/zipCode/current'
    @query = {
      'format' => 'application/json',
      'zipCode' => zip_code,
      'distance' => @distance,
      'API_KEY' => @api_key
    }

    @uri = URI(@url)
    @uri.path = @path
    @uri.query = URI.encode_www_form(@query)

    @response = Net::HTTP.get(@uri)
    @output = JSON.parse(@response)

    # check for empty return result
    if !@output || @output.empty?
      @aqi = 'Error'
    else
      @aqi = @output.dig(0, 'AQI')
      @status_text = @output.dig(0, 'Category', 'Name')
      @reporting_area = @output.dig(0, 'ReportingArea')

      case @aqi.to_i
      when 0..50
        @status_color = 'bg-ozone-good'
      when 51..100
        @status_color = 'bg-ozone-moderate'
      when 101..150
        @status_color = 'bg-ozone-unhealthy-sensitive'
      when 151..200
        @status_color = 'bg-ozone-unhealthy'
      when 201..300
        @status_color = 'bg-ozone-very-unhealthy'
      when 301..500
        @status_color = 'bg-ozone-hazardous'
      else
        @status_text = @status_text || 'Error'
      end
    end
  end

end
