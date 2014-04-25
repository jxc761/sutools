# @copyright 
# author: Jing Chen
# version: v 1.0
# date: March 20, 2014
# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/special_geom.rb")
module CWRU
	
	class SpecialGeom
		# apex: Geom::Point3d
		# base: CWRU::Rect
		
		def initialize(apex, base, ratio)
			@apex = apex
			@base = base
			@ratio = ratio
		end
		
		def get_mid_rect()	
			# the center of the rectanguluar
			center = @base.center
			vd = center - @apex
			vd.length= vd.length * @ratio
			newCenter = @apex + vd
			
			# the new axis of of the rectanguluar
			halfx = @base.halfx.clone()
			halfy = @base.halfy.clone()
			
			halfx.length= halfx.length * @ratio
			halfy.length= halfy.length * @ratio
			
			return Rect.new(newCenter, halfx, halfy)
			
		end
		
		def get_base_rect()
			return @base
		end
		
		
		def drawBasePlane(ent)
			return @base.drawFace(ent)
		end
		
		def drawMidPlane(ent)
			midRect = get_mid_rect()
			return midRect.drawFace(ent)	
		end
		
		def drawBaseToApex(ent)
			
			pts = @base.corners()
			
			e0 = ent.add_line(@apex, pts[0])
			e1 = ent.add_line(@apex, pts[1])
			e2 = ent.add_line(@apex, pts[2])
			e3 = ent.add_line(@apex, pts[3])
			
			return [e0, e1, e2, e3]
		end
		
		
		def drawMidToApex(ent)
			midRect = get_mid_rect()
			pts = midRect.corners()
			
			e0 = ent.add_line(@apex, pts[0])
			e1 = ent.add_line(@apex, pts[1])
			e2 = ent.add_line(@apex, pts[2])
			e3 = ent.add_line(@apex, pts[3])
			
			return [e0, e1, e2, e3]
		end
		
		def drawCenterLine(ent)
			return ent.add_line(@apex, @base.center)
		end
		
		def draw(ent, is_show_base_plane, is_show_mid_plane)
			new_entities = {}
			new_entities["center_line"] = drawCenterLine(ent)
			
			is_show_mid_to_apex = false
			if is_show_base_plane
				new_entities["base_plane"] = drawBasePlane(ent)
				new_entities["base_to_apex"] = drawBaseToApex(ent)
				is_show_mid_to_apex =  true
			end
			
			if is_show_mid_plane
				new_entities["mid_plane"] = drawMidPlane(ent)
				is_show_mid_to_apex =  true
			end
			
			if is_show_mid_to_apex
				new_entities["mid_to_apex"] = drawMidToApex(ent)
			end
			
			return new_entities
		end
		
		def drawSmall(ent)
			new_entities = {}
			
			# draw the plane between apex and base
			midRect = get_mid_rect()
			mid_face = midRect.drawFace(ent)
			new_entities["mid_face"] = mid_face
			
			# draw lines connect apex to mid-rect corners
			midRect = get_mid_rect()
			pts = midRect.corners()
			
			e0 = ent.add_line(@apex, pts[0])
			e1 = ent.add_line(@apex, pts[1])
			e2 = ent.add_line(@apex, pts[2])
			e3 = ent.add_line(@apex, pts[3])
			
			# draw lines connect apex to base's center
			e4 = ent.add_line(@apex, @base.center)
			new_entities["edges"] = [e0, e1, e2, e3, e4]
		
			return new_entities
		end
		
		def drawFull(ent)
			
			new_entities = {}
			
			# draw base
			new_entities["base_edges"] = @base.drawEdges(ent)
			
			# draw lines connect apex to base corners and its center
			pts = @base.corners()
			
			e0 = ent.add_line(@apex, pts[0])
			e1 = ent.add_line(@apex, pts[1])
			e2 = ent.add_line(@apex, pts[2])
			e3 = ent.add_line(@apex, pts[3])
			e4 = ent.add_line(@apex, @base.center)
			
			new_entities["edges"] = [e0, e1, e2, e3, e4]
			
			
			# draw the plane between apex and base
			midRect = get_mid_rect()
			mid_face = midRect.drawFace(ent)
			new_entities["mid_face"] = mid_face
			
			return new_entities
			
		end
		
		
	end
	
	class Rect
		
		def Rect.from(center, x, y, halfx, halfy)
			nx = x
			ny = y
			nx.length=  halfx
			ny.length=  halfy
			return Rect.new(center, nx, ny)
		end
		
		# center: Geom::Point3d
		# half_axis_x: Geom::Vector3d
		# half_axis_y: Geom::Vector3d
		def initialize(center, half_axis_x, half_axis_y)
			@center = center
			@halfx = half_axis_x
			@halfy = half_axis_y
		end
		
		
		def center 
			@center 
		end
		def halfx
			@halfx
		end
		
		def halfy
			@halfy
		end
		
		def size()
			return [@halfx.length * 2, @halfy.length * 2]
		end
		
		def corners()
			p1 = @center - @halfx - @halfy
			p2 = @center + @halfx - @halfy
			p3 = @center + @halfx + @halfy
			p4 = @center - @halfx + @halfy
			return [p1, p2, p3, p4]
		end
		
		
		def drawEdges(ent)
			pts = corners()
			return ent.add_edges(pts[0], pts[1], pts[2], pts[3], pts[0])
		end
		
		def drawFace(ent)
			pts = corners()
			return ent.add_face(pts)
		end
	end
	
end
