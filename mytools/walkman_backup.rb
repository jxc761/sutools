require "sketchup.rb"

class CWalkman
	
	
	def initialize(instance, target)
		@walk_man = instance
		@target = target
	end
		
	def eye
		t = @walk_man.transformation
		ve = t.zaxis.clone
		ve.length= 1.65.m
		eye = t.origin + ve
		return eye
	end
	
	def up
		return @walk_man.transformation.zaxis
	end	
	
	def target
		return @target
	end
	
	
end