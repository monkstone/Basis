class Transform
	attr_accessor :scale, :origin
	def initialize(scale, origin)
		@origin = origin
		@scale = scale
	end

	def apply(p)
		{ :x => @origin[:x] + p[:x] * @scale[:x], :y => @origin[:y] + p[:y] * @scale[:y]}
	end

	def unapply(p)
		{ :x =>  (p[:x] - @origin[:x]) / @scale[:x], :y =>  (p[:y] - @origin[:y]) / @scale[:y]}
	end

	def signed
		Transform.new({:x => (@scale[:x]<=>0.0).to_i, :y => (@scale[:y]<=>0.0).to_i}, @origin)
	end
end

class SignedTransform < Transform
	def apply(p)
		{ :x => @origin[:x] + p[:x] * (@scale[:x]<=>0.0).to_i, :y => @origin[:y] + p[:y] * (@scale[:y]<=>0.0).to_i}
	end
end

