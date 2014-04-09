# MyTool by  Jing Chen

require "sketchup.rb"
require "#{File.dirname(__FILE__)}/mytools/visualize_camera.rb"

class TestMyOrbitTool

def initialize
	@ip1 = nil
	@vetorZ=Geom::Vector3d.new(0.0, 0.0, 1.0)
	@msg1="Center and Target Lock: Double-click [or] Rotate: Left/Right/Up/Down [or] Zoom: Shift+UP/DOWN"
	end

def activate
	Sketchup.set_status_text(@msg1, SB_PROMPT)
	@xant=0.0
	@yant=0.0
	@camera = Sketchup.active_model.active_view.camera
	@ip1 = Sketchup::InputPoint.new
	@target=@camera.target
	reView
  puts('activate')
end

def deactivate(view)
	# $NKJancy_target=@target
  puts('deactivate')
end

def onLButtonDown(flags, x, y, view)
	Sketchup.set_status_text(@msg1, SB_PROMPT)
end

def onLButtonDoubleClick(flags, x, y, view)
	# 0=none / 1=Left / 2=Right / 4=Shift / 8=Ctrl / 16=??? / 32=Alt  / Alt Gr = alt + ctrl
	@ip1.pick(view, x, y)
	if( @ip1.valid? )
		@target=@ip1.position
		reView
	end
end

 def onKeyDown(key, repeat, flags, view)
   puts "onKeyDown: key = " + key.to_s
   puts "        repeat = " + repeat.to_s
   puts "         flags = " + flags.to_s
   puts "          view = " + view.to_s
   

   
   if (flags & VK_SHIFT) != 0 then
       pp = 0.0
     if key == VK_UP then 
  	   pp = 0.05
     elsif key == VK_DOWN then
      pp = -0.05
    end 
    Zoom(pp)
    
    puts "zoomed"
   else
     deltaH = 0.0
     deltaV = 0.0
     if key== VK_LEFT then
    	  deltaH = 0.025
     elsif key == VK_RIGHT then
   	    deltaH = -0.025
     elsif key == VK_UP then
        deltaV = 0.025
     elsif key == VK_DOWN then
   		deltaV = -0.025
     end 
     
     if (flags & VK_ALT) != 0 && (key != VK_ALT)then
         genScences(deltaH, deltaV)
     else 
         Rotate(deltaH, deltaV)
     end
     puts "roated"
   end
  
end


#######
def genScences(deltaH, deltaV)
  pages = Sketchup.active_model.pages
  
  for i in 0..5
    Rotate(deltaH, deltaV)
    pages.add
    pages[pages.count-1].camera.set(@camera.eye, @camera.target, @camera.up)    
    @camera = pages[pages.count-1].camera
  end
  @camera= Sketchup.active_model.active_view.camera
end

def Rotate(deltaH, deltaV)
  e1=@camera.eye
	transf1 = Geom::Transformation.rotation(@target, @vetorZ, deltaH)
	e1.transform!(transf1) # Move Eye com Rotacao em torno de Z e centro em T
	@vetorH.transform!(transf1)
	@vetorT.transform!(transf1)
	@center.transform!(transf1) # Move C com Rotacao em torno de Z e centro em T
   
   
	vetorN=Geom::Vector3d.new(@vetorH.y,-1.0*@vetorH.x,0)
	transf2 = Geom::Transformation.rotation(@target, vetorN, deltaV)
	e1.transform!(transf2) # transf Vert do Eye
	@vetorT.transform!(transf2)
	@center.transform!(transf2) # Move C com Rotacao em torno da Normal ao Plano Vertical e centro em T	
  
  @camera.set(e1,@center,@vetorT)
end


def Zoom(pp)
	e1=Geom::Point3d.linear_combination((1.0-pp),@camera.eye,pp, @target)
	@center=Geom::Point3d.linear_combination((1.0-pp),@camera.target, pp, @target)
	@camera.set(e1,@center,@camera.up)
end

def draw(view)
	@ip1.draw(view)
end

def reView
	@center=@target.clone
	@vetorH=Geom::Vector3d.new(@camera.eye.x-@target.x,@camera.eye.y-@target.y,0.0)
	angV=Math.asin((@camera.eye.z-@target.z)/@camera.eye.distance(@target))+0.5*Math::PI
	vetorN=Geom::Vector3d.new(@vetorH.y,-1.0*@vetorH.x,0)
	@vetorT=@vetorH.transform(Geom::Transformation.rotation(@target, vetorN, angV))
	@camera.set(@camera.eye,@target,@vetorT)
end
	
def resume(view)
	Sketchup.set_status_text(@msg1, SB_PROMPT)
	@target=@camera.target
	reView
end

end # class TestMyOrbitTool

def myOrbitTool
	myTool=Sketchup.active_model.select_tool(TestMyOrbitTool.new)
end


def exportMXS
  
  pages = Sketchup.active_model.pages
  
  pages.each {|page|
    page.camera.aspect_ratio=1.0
  }
  
  MX::Export.export('mxs') 
  
end

def show_camera()
	CWRU::create_observers()
end
############################
def exportCameraSetting
    
  path_to_save_to = UI.savepanel("Save Camera Setting", Sketchup.active_model.path, "#{Sketchup.active_model.name}.txt")
  pages = Sketchup.active_model.pages
  
  if ( (path_to_save_to != nil) && (pages != nil) )
    file = File.new(path_to_save_to,"w+")
    
    file.puts  "model : #{Sketchup.active_model.name}"
    
    pages.each {|page| 
      file.puts "page: #{page.name}"
      file.puts "  target       : #{page.camera.target.to_s}"
      file.puts "  eye          : #{page.camera.eye.to_s}" 
      file.puts "  up           : #{page.camera.up.to_s}"
      file.puts "  fov          : #{page.camera.fov.to_s}"
      file.puts "  focal_length : #{page.camera.focal_length.to_s}"  
    }
   
    file.close
    puts "Saved!!"
  end
  
end


####
def genDots
  

  #Sketchup.active_model.entities.clear!
 
  list = Sketchup.active_model.definitions
  com_def = list.add "ball"

  ent = com_def.entities
  edges1 = ent.add_circle [0,0,0], [0,0,1], 100, 40
  face1 = ent.add_face edges1
  edges2 = ent.add_circle [0,0,0], [0, 1, 0], 200, 40
  face2 = ent.add_face edges2
  face1.followme edges2
  ent.erase_entities edges2
  

  group = Sketchup.active_model.entities.add_group
  for i in 0..10
    x = rand(50)*100 
    y = rand(50)*100 
    z = rand(50)*100 
    pt = Geom::Point3d.new(x, y, z)
    transformation = Geom::Transformation.new(pt) 
  
  
    componentinstance = group.entities.add_instance(com_def, transformation) 
  
  end
  
  grayMat = Sketchup.active_model.materials.add "gray"
  grayMat.color = Sketchup::Color.new(240, 240, 240)
  
  targetMat = Sketchup.active_model.materials.add "target"
  grayMat.color = Sketchup::Color.new(0, 240, 0)
  
  Sketchup.active_model.active_view.refresh
end

############################
if not file_loaded?(__FILE__ )
  
	cmd = UI::Command.new("MyOrbitTool") { myOrbitTool }
	cmd.small_icon = "./MyTools/icons/target_16.png"
	cmd.large_icon = "./MyTools/icons/target_24.png"
	cmd.menu_text = "MyOrbitTool"
	cmd.tooltip = "Target: Rotate, Zoom,"
	cmd.status_bar_text = "OrbitOnTarget: Center, Rotate, Zoom"
  
	cmd_export = UI::Command.new("ExportCameraSetting") { exportCameraSetting }
	cmd_export.small_icon = "./MyTools/icons/export_16.png"
	cmd_export.large_icon = "./MyTools/icons/export_24.png"
	cmd_export.menu_text = "Export Camera"
	cmd_export.tooltip = "Export camera setting to a xml file"
	cmd.status_bar_text = "Export camera setting to a xml file"
  
  
	cmd_gendots = UI::Command.new("GenerateDots") { genDots }
	cmd_gendots.small_icon = "./MyTools/icons/dots_16.png"
	cmd_gendots.large_icon = "./MyTools/icons/dots_24.png"
	cmd_gendots.menu_text = "Generate Dots"
	cmd_gendots.tooltip = "Generate a set of dots"
	cmd_gendots.status_bar_text = "Generating dots"
  
	cmd_camera = UI::Command.new("Camera") {  show_camera }
	cmd_camera.small_icon = "./MyTools/icons/camera_16.png"
	cmd_camera.large_icon = "./MyTools/icons/camera_24.png"
	cmd_camera.menu_text = "Show Camera"
	cmd_camera.tooltip = "Show Camera"
	cmd_camera.status_bar_text = "Show Camera"
	
	nkjancyBar = UI::Toolbar.new("MyTools")
	nkjancyBar.add_item(cmd)
	nkjancyBar.add_item(cmd_export)
	nkjancyBar.add_item(cmd_gendots)	
	nkjancyBar.add_item(cmd_camera)
  
end

file_loaded(__FILE__ )
