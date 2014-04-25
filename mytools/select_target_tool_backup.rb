
class CSelectTargetTool

	def reset()
		@observer = nil
		@mouse = nil
		@target = nil
	end
	
	
	def activate
		reset()
	end
	
	def deactivate(view)
		reset()
		view.invalidate 
	end
	
	
	def get_status()
		if @observer == nil
			return "pick_observer"
		end
		
		if @target == nil
			return "pick_target"
		end
		
		return "walk"
	end
	
	
    def onKeyDown(key, repeat, flags, view)
		if get_status() != "walk"
			return
		end
	
		t_org = @observer.transformation
		v0 = Geom::Vector3d.new 0,0,0
		case key
		when VK_LEFT
			tranform = Geom::Transformation.translation t_org.xaxis
		when VK_RIGHT
			v = v0- t_org.xaxis
			tranform = Geom::Transformation.translation v
		when VK_UP
			v = v0 - t_org.yaxis 
			tranform = Geom::Transformation.translation v
		when VK_DOWN
			tranform = Geom::Transformation.translation t_org.yaxis
		else
			tranform = Geom::Transformation.translation
		end
		@observer.transformation= tranform * t_org
		#update(view)
    end
	
	def onLButtonDoubleClick(flags, x, y, view)
		@observer = select_observer(x, y, view)
		if @observer == nil
			reset()
		else
			selection = Sketchup.active_model.selection
			selection.clear
			selection.add(@observer)
		end
		view.invalidate 
	end
	
	def onMouseMove(flags, x, y, view)
		@mouse = view.inputpoint(x,y)
		view.invalidate
	end
	
	def onRButtonDoubleClick(flags, x, y, view)
		if get_status() != "pick_target"
			view.invalidate
			return
		end
		
		
		@target =  select_target(x, y, view)
		if @target != nil
			camera=view.camera
			camera.set(get_eye(), @target, get_up())
		end
		
		view.invalidate
	end
	
	def draw(view)
		
		if get_status()== "pick_target"
			view.set_color_from_line(get_eye(), @mouse.position)
			view.draw_line(get_eye(), @mouse.position)
			@mouse.draw(view)
		end	
	end
	
	def select_observer(x, y, view)
		ph = view.pick_helper
		ph.do_pick(x, y)
		best_entity = ph.best_picked
		
		if best_entity != nil	
			definition = Sketchup.active_model.definitions["cwru_observer"]
			if best_entity.typename == "ComponentInstance" && definition==best_entity.definition
				return best_entity
			end 
		end
		return nil
	end
	
	def update(view)
		camera=view.camera
		camera.set(get_eye(), @target, get_up())
	end
	
	def select_target(x, y, view)
		inputpoint = view.inputpoint x,y 
		if( inputpoint.valid? )
			return inputpoint.position
		end
		return nil
	end
	
	
	def get_eye()
		if @observer == nil
			return nil
		end
		
		t = @observer.transformation
		ve = t.zaxis.clone
		ve.length= 1.7.m
		eye = t.origin + ve
		return eye
	end

	def get_up()
		if @observer == nil
			return nil
		end
		return @observer.transformation.zaxis
	end
	
end

