=begin

Copyright (c) 2014, Sameer Deshmukh
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=end

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
    # makes fancy index work
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
