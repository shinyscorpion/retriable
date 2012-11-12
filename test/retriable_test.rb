# encoding: utf-8

require 'retriable'
require 'minitest/autorun'

class RetriableTest < MiniTest::Unit::TestCase
  TestError = Class.new StandardError

  def test_without_arguments
    i = 0

    retriable do
      i += 1
      raise StandardError.new
    end
  rescue StandardError
    assert_equal 3, i
  end

  def test_with_one_exception_and_two_tries
    i = 0

    retriable :on => EOFError, :tries => 2 do
      i += 1
      raise EOFError.new
    end

  rescue EOFError
    assert_equal i, 2
  end

  def test_with_arguments
    i = 0

    on_retry = Proc.new do |exception, tries|
      assert_equal exception.class, ArgumentError
      assert_equal i, tries
    end

    retriable :on => [EOFError, ArgumentError], :on_retry => on_retry, :tries => 5, :sleep => 0.2 do |h|
      i += 1
      raise ArgumentError.new
    end

  rescue ArgumentError
    assert_equal 5, i
  end
  
  def test_with_on_return_and_criteria_was_met
    i = 0
    
    tries_values = [1,2,3]
    retry_if_less_than_three = Proc.new do |return_value, tries|
      expected_param_value = tries_values.shift
      assert_equal expected_param_value, tries
      assert_equal return_value, tries

      return_value < 3 
    end
    
    return_values = [1,2,3,4,5]
    retriable :on_return => retry_if_less_than_three, :tries => 5 do
      i += 1
      return_values.shift
    end

    assert_equal 3, i
  end

  def test_with_on_return_and_criteria_was_not_met
    i = 0
    
    tries_values = [1,2,3,4,5]
    retry_if_less_than_ten = Proc.new do |return_value, tries|
      expected_param_value = tries_values.shift
      assert_equal expected_param_value, tries
      assert_equal return_value, tries

      return_value < 10 
    end
    
    return_values = [1,2,3,4,5]
    result = retriable :on_return => retry_if_less_than_ten, :tries => 5 do
      i += 1
      return_values.shift
    end

    assert_equal 5, result
    assert_equal 5, i
  end

  def test_sleep_with_proc
    sleep_values = []
    Kernel.send(:define_method, :sleep) do |n|
      sleep_values << n
    end
    
    twice_attempts = Proc.new do |attempt|
      2*attempt
    end

    retriable :interval => twice_attempts, :tries => 4 do 
      raise StandardError
    end
  rescue StandardError
    assert_equal [2,4,6], sleep_values
  end

  def test_with_exception_regex
    begin
      i = 0
      retriable :on => [[TestError, /abc/]], :tries => 2 do
        i += 1
        raise TestError.new('abc')
      end
    rescue TestError
    ensure
      assert_equal i, 2
    end

    begin
      i = 0
      retriable :on => [[TestError, /abc/]], :tries => 2 do
        i += 1
        raise TestError.new('xyz')
      end
    rescue TestError
    ensure
      assert_equal i, 1
    end
  end
end
