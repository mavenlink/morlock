require 'spec_helper'

describe Morlock do
  describe "#lock" do
    module Dalli
      class Client; end
    end
    class MemCache; end

    context "working with different memcached client gems" do
      describe "with Dalli" do
        before do
          @mock_client = Dalli::Client.new
          stub(@mock_client).delete(anything)
        end

        it "should issue a memcached add command on the given key" do
          mock(@mock_client).add("some_key", 1, 60)
          morlock = Morlock.new(@mock_client)
          morlock.lock("some_key", :expiration => 60)
        end

        it "should return true when the lock is acquired" do
          mock(@mock_client).add("some_key", 1, 60) { true }
          morlock = Morlock.new(@mock_client)
          morlock.lock("some_key", :expiration => 60).should == true
        end

        it "should return false when the lock is not acquired" do
          mock(@mock_client).add("some_key", 1, 60) { false }
          morlock = Morlock.new(@mock_client)
          morlock.lock("some_key", :expiration => 60).should == false
        end
      end

      describe "with MemCache" do
        before do
          @mock_client = MemCache.new
          stub(@mock_client).delete(anything)
        end

        it "should issue a memcached add command on the given key" do
          mock(@mock_client).add("some_key", 1, 60, true)
          morlock = Morlock.new(@mock_client)
          morlock.lock("some_key", :expiration => 60)
        end

        it "should return true when the lock is acquired" do
          mock(@mock_client).add("some_key", 1, 60, true) { "STORED\r\n" }
          morlock = Morlock.new(@mock_client)
          morlock.lock("some_key", :expiration => 60).should == true
        end

        it "should return false when the lock is not acquired" do
          mock(@mock_client).add("some_key", 1, 60, true) { "NOT_STORED\r\n" }
          morlock = Morlock.new(@mock_client)
          morlock.lock("some_key", :expiration => 60).should == false
        end
      end
    end

    context "general behavior" do
      before do
        @mock_client = Dalli::Client.new
        @morlock = Morlock.new(@mock_client)
      end

      def lock_will_succeed
        key = nil
        mock(@mock_client).add(anything, anything, anything) { |k| key = k; true }
        mock(@mock_client).delete(anything) { |k| k.should == key }
      end

      def lock_will_fail
        mock(@mock_client).add(anything, anything, anything) { |k| false }
        do_not_allow(@mock_client).delete
      end

      it "should yield on success" do
        lock_will_succeed
        yielded = false
        @morlock.lock("some_key") do
          yielded = true
        end
        yielded.should be_true
      end

      it "should not yield on failure" do
        lock_will_fail
        yielded = false
        @morlock.lock("some_key") do
          yielded = true
        end
        yielded.should be_false
      end

      it "should accept :success and :failure procs and call :success on success" do
        lock_will_succeed
        failed, succeeded = nil, nil
        @morlock.lock("some_key", :failure => lambda { failed = true }, :success => lambda { succeeded = true })
        failed.should be_nil
        succeeded.should be_true
      end

      it "should accept :success and :failure procs and call :failure on failure" do
        lock_will_fail
        failed, succeeded = nil, nil
        @morlock.lock("some_key", :failure => lambda { failed = true }, :success => lambda { succeeded = true })
        failed.should be_true
        succeeded.should be_nil
      end

      it "should return false on failure" do
        lock_will_fail
        @morlock.lock("some_key").should be_false
      end

      it "should return true on success" do
        lock_will_succeed
        @morlock.lock("some_key").should be_true
      end
    end
  end
end