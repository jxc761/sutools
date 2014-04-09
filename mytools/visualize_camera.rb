# @copyright 
# author: Jing Chen
# version: v 1.0
# date: March 20, 2014
require "sketchup"
require "#{File.dirname(__FILE__)}/visible_camera.rb"
require "#{File.dirname(__FILE__)}/special_geom.rb"

#load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/visualize_camera.rb")
module CWRU

	def self.create_observer(texture_path)

		model  =  ::Sketchup.active_model
		view   =  model.active_view
		camera =  view.camera
		
		height = view.vpheight
		width  = view.vpwidth
		
		# create the geometry which represent the camera
		eye 		= camera.eye
		target 		= camera.target
		up 			= camera.up
		
		aspect_ratio = width * 1.0 / height * 1.0
		fov          = view.camera.fov.degrees
		ratio        = 0.2
		
		visibleCamera = VisibleCamera.new(eye, target, up, fov, aspect_ratio, ratio)
		
		# draw it into model
		group         = model.entities.add_group
		entities      = visibleCamera.draw(group.entities)
		
		image_plane   = entities["mid_plane"]
		rect          = visibleCamera.get_image_rect
		#image_plane		= entities["base_plane"]
		#rect			= visibleCamera.get_focal_plane
		
		
		mat = model.materials.add
		mat.texture= texture_path
		on_front = true
		
		pts = rect.corners
		mapping = [pts[0], [0, 0], pts[1], [1, 0], pts[2], [1, 1], pts[3], [0, 1]]

		
		image_plane.position_material(mat, mapping, on_front)
		return group
	end
	
	def self.create_observers()
		
		model = ::Sketchup.active_model
		pages = model.pages
		
		# if no page in current model, then add a new page
		if pages.count == 0
			pages.add
		end
		
		# save the image of each page
		export_pages_to_images()
		
		showtransitions = model.options["PageOptions"]["ShowTransition"]
		model.options["PageOptions"]["ShowTransition"] = false
		path = (model.path.sub(/.skp/," - "))
		
		pages.each do |page|
			pages.selected_page= page
			texture_path = path + (page.name.to_s)+".jpg"
		 	group=create_observer(texture_path)
		end
		
		
		# add new page to show changes
		new_page = pages.add
		pages.selected_page=new_page
		model.active_view.zoom_extents
		new_page.update
		
		model.options["PageOptions"]["ShowTransition"] = showtransitions
	
	end
	
	def self.export_pages_to_images
		model = Sketchup.active_model
		pages = model.pages
		view = model.active_view
		
		original_page = pages.selected_page
		model.start_operation "ExportScenes"

		showtransitions = model.options["PageOptions"]["ShowTransition"]
		model.options["PageOptions"]["ShowTransition"] = false

		path = (model.path.sub(/.skp/," - "))

		pages.each { |page|
			pn = path+(page.name.to_s)+".jpg"
			Sketchup.set_status_text("Writing #{pn}")
			pages.selected_page= page
			view.write_image(pn,view.vpwidth,view.vpheight,true)
				
		}

		model.options["PageOptions"]["ShowTransition"] = showtransitions
		pages.selected_page= original_page
		
		model.abort_operation

	end
	
end