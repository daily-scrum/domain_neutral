class ActiveSupport::TestCase
  class CacheStub
    def initialize(test_object, *expected_params)
      @test_object, @expected_params = test_object, expected_params
    end
    
    def fetch(*params, &block)
      @called = :fetch
      @test_object.assert_equal @expected_params, params
      block.call
    end
    def delete(*params)
      @called = :delete
      @test_object.assert_equal @expected_params, params
    end
    def called?(method)
      @called == method
    end
  end
  
  # expects a call to cache with certain attributes
  #
  #  Example:
  #   expect_cached ['Cal::Bingo::Room', :accessible], expires_in: 5.minutes do
  #     Cal::Bingo::Room.expects(:where).with(deleted: 0).returns rooms
  #     @rooms = Cal::Bingo::Room.accessible
  #   end
  
  def expect_cached(*params, &block)
    _cache(:fetch, *params, &block)
  end
  
  # expects a call to cache with certain attributes
  #
  #  Example:
  #   expect_cache_deleted 'Cal::Bingo::Room', :accessible do
  #      Cal::Bingo::Room.update_attributes(voila, :wow)
  #   end
  def expect_cache_deleted(*params, &block)
    _cache(:delete, *params, &block)
  end

  def _cache(expected_method, *params, &block) #nodoc
    raise ArgumentError, 'You must specify block' unless block_given?
    cache = CacheStub.new(self, *params)
    Rails.stubs(:cache).returns(cache)
    yield
    assert cache.called?(expected_method), "cache #{expected_method} was never called\n #{caller[1]}"
    Rails.unstub(:cache)
  end

  def expect_nothing_cached(&block)
    raise ArgumentError, 'You must specify block' unless block_given?
    Rails.expects(:cache).never
    yield
  end
end