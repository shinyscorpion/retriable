 # encoding: utf-8

require 'timeout'

module Retriable
  extend self

  class Retry
    attr_accessor :tries
    attr_accessor :interval
    attr_accessor :timeout
    attr_accessor :on
    attr_accessor :on_retry

    def initialize
      @tries      = 3
      @interval   = 0
      @timeout    = nil
      @on         = [StandardError, Timeout::Error]
      @on_retry   = nil

      yield self if block_given?
    end

    def perform
      count = 0
      begin
        if @timeout
          Timeout::timeout(@timeout) { yield }
        else
          yield
        end
      rescue Exception => exception
        if matches_exception_spec? exception
          @tries -= 1
          if @tries > 0
            count += 1
            sleep @interval if @interval > 0
            @on_retry.call(exception, count) if @on_retry
            retry
          else
            raise
          end
        else
          raise
        end
      end
    end

    def matches_exception_spec? exception
      [*on].any?{|exception_spec|
        pattern = nil
        if exception_spec.is_a? Array
          spec_exception, pattern = exception_spec
        else
          spec_exception = exception_spec
        end
        match = exception.is_a?(spec_exception)
        if pattern
          match &&= exception.message =~ pattern
        end
        match
      }
    end
  end

  def retriable(opts = {}, &block)
    raise 'no block given' unless block_given?

    Retry.new do |r|
      r.tries      = opts[:tries] if opts[:tries]
      r.on         = opts[:on] if opts[:on]
      r.interval   = opts[:interval] if opts[:interval]
      r.timeout    = opts[:timeout] if opts[:timeout]
      r.on_retry   = opts[:on_retry] if opts[:on_retry]
    end.perform(&block)
  end
end
