module Daru
  # Extend Daru DataFrame
  class DataFrame
    # makes categorical data into 0/1 vectors
    def one_hot_encoding target_vectors
      target_vectors.each do |vector|
        currernt_vector = @data[@vectors[vector]].map(&:strip)
        size = currernt_vector.uniq.size
        (0...size - 1).each do |num|
          val = currernt_vector.uniq[num]
          binary_vec = currernt_vector.map { |x| x == val ? 1 : 0 }
          @data << Daru::Vector.new(binary_vec, name: vector + '_' + val.strip)
          @vectors = Daru::Index.new @vectors.to_a + [vector + '_' + val.strip]
        end # size iteration is over
        @data.delete_at @vectors[vector]
        @vectors = Daru::Index.new @vectors.to_a - [vector]
      end # namearray iteration is over
      self
    end # def over
    # makes [] work with array
    def access_vector *names
      # Only this line is added
      names = names[0] if names[0].class == Array
      # end

      location = names[0]

      return dup(@vectors[location]) if location.is_a?(Range)
      if @vectors.is_a?(MultiIndex)
        pos = @vectors[names]

        return @data[pos] if pos.is_a?(Integer)

        # MultiIndex
        new_vectors = pos.map do |tuple|
          @data[@vectors[tuple]]
        end

        if !location.is_a?(Range) && names.size < @vectors.width
          pos = pos.drop_left_level names.size
        end

        Daru::DataFrame.new(new_vectors, index: @index, order: pos)
      else
        unless names[1]
          pos = @vectors[location]

          return @data[pos] if pos.is_a?(Numeric)

          names = pos
        end

        new_vectors = {}
        names.each do |name|
          new_vectors[name] = @data[@vectors[name]]
        end

        order = names.is_a?(Array) ? Daru::Index.new(names) : names
        Daru::DataFrame.new(new_vectors, order: order,
                                         index: @index, name: @name)
      end
    end # def over
  end # class over
end # Module over
