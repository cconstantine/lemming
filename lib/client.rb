require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'benchmark'
require 'timeout'


Capybara.run_server = false
Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

#Syslog.open("perftest", Syslog::LOG_PID, Syslog::LOG_DAEMON | Syslog::LOG_LOCAL7)

module Lemming
  class Client
    attr_reader :session
    include Capybara::DSL

    def initialize(app_host, out_stream=nil)
      Capybara.app_host = app_host
      @out_stream = out_stream
      #@session = Capybara::Session.new(:webkit)
      #@session.driver.enable_logging
      page.driver.browser.ignore_ssl_errors
    end

    def timeout
      20
    end

    def measure(name, to=timeout, &block)
      error = nil
      dt = Benchmark.realtime do
        #puts "#{Process.pid}: Visiting #{path}"
        begin
          Timeout::timeout(to) do
            yield block
          end
        rescue Exception, Timeout::Error => e
          #p "***************************** #{name}"
          error = e
        end
      end
    ensure
      log(dt, page.status_code, name, error)

      if error != nil
        #puts "Throwing for #{name}"
        raise error
      end
    end

    def visit_measure( path)
      measure("visit #{path}") do
        visit_without_measure(path)
      end
    end
    alias_method :visit_without_measure, :visit
    alias_method :visit, :visit_measure

    def click_on_with_measure(name)
      measure("click_on '#{name}'") do
        click_on_without_measure name

      end
    end
    alias_method :click_on_without_measure, :click_on
    alias_method :click_on, :click_on_with_measure

    def click_button_with_measure(name)
      measure("click_on '#{name}'") do
        click_button_without_measure name
      end
    end
    alias_method :click_button_without_measure, :click_button
    alias_method :click_button, :click_button_with_measure

    def log(dt, status, name, error)
      r = {dt: dt, status: status, name:name, error:error}
      if @out_stream
        @out_stream.puts("#{r.to_json}\n")
        #@out_stream.puts("#{Process.pid}, #{Time.now.to_i} #{dt}, #{status}, #{name}, #{error ? error.message : ""}")
      end
      output("#{Process.pid}: #{dt.round(2)} | #{status} | #{name}")
    end

    protected
    def output(msg)
      #$stderr.puts msg
      #Syslog.log(Syslog::LOG_LOCAL7, msg)
    end


  end
end