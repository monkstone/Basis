require 'rubygems'

Gem.clear_paths
ENV['GEM_HOME'] = '/home/avishek/jruby/jruby-1.6.4/lib/ruby/gems/1.8'
ENV['GEM_PATH'] = '/home/avishek/jruby/jruby-1.6.4/lib/ruby/gems/1.8'

require 'basis_processing'

class Demo < Processing::App
	app = self
	def setup
		render_mode(P2D)
		no_loop
		background(0,0,0)
		color_mode(RGB, 1.0)
		stroke(1,1,0,1)
		@highlight_block = lambda do |original, mapped, s|
					s.in_basis do
						rect_mode(CENTER)
						stroke(1,0,0)
						fill(1,0,0)
						rect(original[:x], original[:y], 6, 6)
					end
				   end

		points = []
		200.times {|n|points << {:x => n, :y => random(300)}}

		@x_unit_vector = {:x => 1.0, :y => 1.0}
		@y_unit_vector = {:x => -1.0, :y => 1.0}
		x_range = ContinuousRange.new({:minimum => 0, :maximum => 200})
		y_range = ContinuousRange.new({:minimum => 0, :maximum => 300})
		@basis = CoordinateSystem.new(Axis.new(@x_unit_vector,x_range), Axis.new(@y_unit_vector,y_range), self, [[1,0],[0,1]])

		screen_transform = Transform.new({:x => 2, :y => -2}, {:x => 600, :y => 1000})
		@screen = Screen.new(screen_transform, self, @basis)
		@screen.draw_axes(10,10)
		stroke(1,1,0,1)
		fill(1,1,0)
		rect_mode(CENTER)
		points.each do |p|
			@screen.plot(p, :track => true) do |original, mapped, s|
				s.in_basis do
					rect(original[:x], original[:y], 3, 3)
				end
			end
		end
	end
	
	def draw
	end
end

w = 1200
h = 1000

Demo.send :include, Interactive
Demo.new(:title => "My Sketch", :width => w, :height => h)

