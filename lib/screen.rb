require 'transform'
require 'knnball'
require 'text_output'

class Screen
	attr_accessor :points

	def join=(should_join)
		@should_join = should_join
		@buffer = nil if !@should_join
	end
	
	def initialize(transform, artist, basis, output=TextOutput.new)
		@transform = transform
		@artist = artist
		@basis = basis
		join = false
		@points = []
		@data = []
		@output = output
	end

	def build
		KnnBall.build(@data)
	end

	def draw_crosshairs(p)
		@basis.crosshairs(p).each do |hair|
			from = @transform.apply(hair[:from])
			to = @transform.apply(hair[:to])
			@artist.line(from[:x], from[:y], to[:x], to[:y])
		end
	end

	def plot(point, options = {:bar => false, :track => false}, &block)
		@points << point if options[:track]
		@data << {:id => @points.count - 1, :point => [point[:x], point[:y]]}
		p = transformed(point)
		standard_x_axis_point = transformed({:x => point[:x], :y => 0})
		if (block)
			block.call(p)
		else
			@artist.ellipse(p[:x], p[:y], 5, 5)
		end
		@artist.line(standard_x_axis_point[:x], standard_x_axis_point[:y], p[:x], p[:y]) if options[:bar]
		return if !@should_join
		@artist.line(@buffer[:x], @buffer[:y], p[:x], p[:y]) if @buffer
		@buffer = p
	end

	def transformed(data_point)
		standard_point = @basis.standard_basis(data_point)
		@transform.apply(standard_point)
	end
	
	def original(onscreen_point)
		p = @transform.unapply(onscreen_point)
		@basis.original(p)
	end

	def draw_ticks(ticks, displacement)
		ticks.each do |l|
			from = l[:from]
			to = l[:to]
			tick_vector = normal(from, to)
			to = {:x => from[:x] + tick_vector[:x], :y => from[:y] + tick_vector[:y]}
			@artist.line(from[:x],from[:y],to[:x],to[:y])
			@artist.fill(1)
			@artist.text(l[:label], to[:x]+displacement[:x], to[:y]+displacement[:y])
		end
	end

	def normal(from, to)
		vector = {:x => to[:x] - from[:x], :y => to[:y] - from[:y]}
		magnitude = sqrt(vector[:x]**2 + vector[:y]**2)
		{:x => 5*vector[:x]/magnitude, :y => 5*vector[:y]/magnitude}
	end

	def draw_axes(x_interval, y_interval)
		f = @artist.createFont("Georgia", 24, true);
		@artist.text_font(f,16)
		axis_screen_transform = Transform.new({:x => 800, :y => -800}, @transform.origin)
		origin = {:x => 0, :y => 0}
		screen_origin = @transform.apply(origin)
		x_basis_edge = axis_screen_transform.apply(@basis.x_basis_vector)
		y_basis_edge = axis_screen_transform.apply(@basis.y_basis_vector)

		x_ticks = @basis.x_ticks(x_interval)
		y_ticks = @basis.y_ticks(y_interval)

		x_ticks = x_ticks.collect {|t| {:from => @transform.apply(t[:from]), :to => @transform.apply(t[:to]), :label => t[:label]}}
		y_ticks = y_ticks.collect {|t| {:from => @transform.apply(t[:from]), :to => @transform.apply(t[:to]), :label => t[:label]}}

		@artist.line(x_ticks.first[:from][:x],x_ticks.first[:from][:y],x_ticks.last[:from][:x],x_ticks.last[:from][:y])
		@artist.line(y_ticks.first[:from][:x],y_ticks.first[:from][:y],y_ticks.last[:from][:x],y_ticks.last[:from][:y])

		draw_ticks(x_ticks, {:x => 0, :y => 20})
		draw_ticks(y_ticks, {:x => -50, :y => 0})
	end
	
	def write(p)
		@output.notify(p)
	end
end

