require 'spec_helper'

describe RescueMe do
  subject { RescueMe }

  def should_return_a_list_of_errors(method)
    errors = subject.send(method)
    errors.class.should == Array
    errors.empty?.should be_false
  end

  describe '.net_http_errors' do
    before :each do
      Net::HTTP.send(:remove_const, :Persistent) if defined? Net::HTTP::Persistent
    end

    it 'should return a list of errors' do
      should_return_a_list_of_errors(:net_http_errors)
    end

    it 'should include Net::HTTP:Persistent::Error if that library is defined' do
      class Net::HTTP::Persistent
        class Error < Exception; end
      end

      subject.net_http_errors.include?(Net::HTTP::Persistent::Error).should be_true
    end

    it 'should not include Net::HTTP:Persistent::Error if that library is not defined' do
      errors = subject.net_http_errors

      # Define this after the method so we can ask the array if it's included.
      class Net::HTTP::Persistent
        class Error < Exception; end
      end

      errors.include?(Net::HTTP::Persistent::Error).should be_false
    end
  end

  describe '.net_smtp_server_errors' do
    it 'should return a list of errors' do
      should_return_a_list_of_errors(:net_smtp_server_errors)
    end

    it 'should include Net::SMTPAuthenticationError' do
      subject.net_smtp_server_errors.include?(Net::SMTPAuthenticationError).should be_true
    end

    it 'should not include Net::SMTPAuthenticationError when disabled' do
      subject.net_smtp_server_errors(:with_auth => false).include?(Net::SMTPAuthenticationError).should be_false
    end
  end
  
  describe '.net_smtp_client_errors' do
    it 'should return a list of errors' do
      should_return_a_list_of_errors(:net_smtp_client_errors)
    end

    it 'should not include Net::SMTPAuthenticationError' do
      subject.net_smtp_client_errors.include?(Net::SMTPAuthenticationError).should be_false
    end
    it 'should include Net::SMTPAuthenticationError when enabled' do
      subject.net_smtp_client_errors(:with_auth => true).include?(Net::SMTPAuthenticationError).should be_true
    end
  end

  describe '.net_smtp_errors' do
    it 'should return a list of errors' do
      should_return_a_list_of_errors(:net_smtp_errors)
    end
  end

  context 'errors with' do
    before :all do
      class FooError < StandardError; end
      class BarError < StandardError; end
      class OrigError < StandardError; end
    end

    let(:test_ary) { [FooError, BarError] }

    before :each do
      subject.stub(:errors => [OrigError])
    end

    context 'a passed array' do
      it 'should include the array' do
        errors = subject.send(:errors_with, :errors, test_ary)

        test_ary.each do |a|
          errors.include?(a).should be_true
        end
      end

      it 'should have the original elements' do
        subject.send(:errors_with, :errors, [FooError, BarError]).include?(OrigError).should be_true
      end
    end

    context 'a single exception' do
      it 'should add the exception' do
        subject.send(:errors_with, :errors, FooError).include?(FooError).should be_true
      end

      it 'should have the original elements' do
        subject.send(:errors_with, :errors, FooError).include?(OrigError).should be_true
      end
    end

    context 'a set' do
      let(:set) { Set.new(test_ary) }

      it 'should add the elements of the set' do
        errors = subject.send(:errors_with, :errors, set)

        set.each do |s|
          errors.include?(s).should be_true
        end
      end

      it 'should have the original elements' do
        errors = subject.send(:errors_with, :errors, set).include?(OrigError).should be_true
      end
    end

    it 'should raise an ArgumentError when a bad argument is passed' do
      lambda { subject.send(:errors_with, :errors, 42) }.should raise_error ArgumentError
    end
  end
end
