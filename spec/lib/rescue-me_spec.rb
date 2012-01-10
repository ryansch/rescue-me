require 'spec_helper'

describe RescueMe do
  subject { RescueMe }

  describe '.net_http_errors' do
    before :each do
      Net::HTTP.send(:remove_const, :Persistent) if defined? Net::HTTP::Persistent
    end

    it 'should return a list of errors' do
      subject.net_http_errors.class.should == Array
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

  end
  
  describe '.net_smtp_client_errors' do

  end

  describe '.net_smtp_errors' do

  end

  context 'errors with' do

  end
end
