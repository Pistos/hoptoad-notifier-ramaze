module Ramaze
  class Session
    class Hash
      # So we can give the session hash data to Hoptoad.
      def to_h
        @hash
      end
    end
  end
end