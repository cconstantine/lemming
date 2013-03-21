require 'rubygems'
require 'benchmark'
require 'timeout'
require 'result_set'
require 'thread'
require 'pty'
require 'open3'
require 'json'
require 'client'

module Lemming
  class Lemming

    attr_accessor :delay, :tick, :total_time, :results

    def initialize(opts=Hash.new)
      @incoming = Queue.new

      self.delay = opts[:delay] || 0.1
      self.tick =  opts[:delay] || 10
      self.total_time =  opts[:delay] || 5 * 60
      @command = opts[:command]

      raise "You must specify a command to run" unless @command

      self.results = ResultSet.new

      Thread.new do
        while true
          begin
            r = @incoming.pop
            results.add(r)
          rescue
            p $!
          end
        end
      end
    end

    def run
      puts "RUNNING #{@command}"
      start = Time.now
      tick_start = Time.now
      while Time.now - start < total_time

        if Time.now - tick_start > tick
          puts  "****************************************************"
          results.report
          results = ResultSet.new
          tick_start = Time.now
        end

        Thread.new do
          Open3.popen3(*@command) do |stdin, stdout, stderr, wait_thr|
            stdout.each_line do |line|
              begin
                @incoming << JSON.parse(line.strip)
              rescue
                puts $!.inspect
              end
            end
            stdin.close
          end
        end
        sleep( delay )
      end

      while !@incoming.empty?;
        p 'not empty'
        sleep 0.1
      end

      results.report
    end
  end
end