# @copyright 
# author: Jing Chen
# version: v 1.0
# date: March 20, 2014

require "#{File.dirname(__FILE__)}/special_geom.rb"

# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/visible_camera.rb")
# 
module CWRU
	class VisibleCamera
		
		def update_wuv()
			a = @eye - @target
			b = @up
			@w= a.normalize
			@u= b.cross(@w).normalize
			@v= @w.cross(@u)
		end
		
		def update_geom()	
			# compute the focal plane
			d = @eye.distance(@target)
			half_height  = Math.tan(@fov/2) * d
			half_width   = half_height * @aspect_ratio
			base = Rect.from(@target, @u, @v, half_width, half_height)
			@geom = SpecialGeom.new(@eye, base, @ratio)
			
		end
		
		# apex: Geom::Point3d
		# base: CWRU::Rect
		# wfov:  unit radians, fov in width direction
		# aspect_ratio: width : height
		def initialize(eye, target, up, fov, aspect_ratio, ratio)
			
			@eye = eye
			@target = target
			@up = up
			@fov = fov
			@aspect_ratio = aspect_ratio
			@ratio = ratio
			
			
			# initilizeUVW 
			update_wuv()

			# compute geom
			update_geom()
			
			
		end
		
		def draw(ent)
			#return @geom.drawSmall(ent)
			return @geom.draw(ent, false, true)
			
		end
		
		def get_focal_rect()
			return @geom.get_base_rect
		end
		
		def get_image_rect()
			return @geom.get_mid_rect
		end

	end
end