#
# =BEGIN MIT LICENSE
# 
# The MIT License (MIT)
#
# Copyright (c) 2014 The CrossBridge Team
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# =END MIT LICENSE
#

.PHONY: init clean all 

$?VGL_TARGETS=	02_matrices_and_coloring_polygons \
	03_the_viewport \
	04_scrolling_and_the_matrix_stack \
	05_texture_mapping_and_pixel_manipulation \
	06_loading_a_texture \
	07_clipping_textures \
	08_non_power_of_2_textures \
	09_updating_textures \
	10_color_keying_and_blending \
	11_stretching_and_filters \
	12_rotation \
	13_matrix_transformations \
	14_repeating_textures \
	15_extensions_and_glew \
	16_vertex_arrays \
	17_vertex_buffer_objects \
	18_textured_vertex_buffers \
	19_sprite_sheets \
	20_bitmap_fonts \
	21_alpha_textures \
	22_texture_blitting_and_texture_padding \
	23_freetype_fonts \
	24_text_alignment \
	25_transforming_text \
	26_the_stencil_buffer \
	27_frame_buffer_objects_and_render_to_texture \
	28_antialiasing_and_multisampling \
	29_hello_glsl \
	30_loading_text_file_shaders \
	31_glsl_matrices_color_and_uniforms \
	32_glm_matrices \
	33_multi-color_polygons_and_attributes \
	34_glsl_texturing \
	35_glsl_font \
	36_vertex_array_objects

all: clean init check $(VGL_TARGETS)
 
#@curl -L -o $@.zip http://lazyfoo.net/tutorials/OpenGL/$@/$@.zip && mv $@.zip temp/ && unzip -qq temp/$@.zip && mv $@ lessons
%:
	# Generate VFS
	@rm -rf lessons/$@/temp/
	@mkdir -p lessons/$@/fs/
	@mkdir -p lessons/$@/temp/
	"$(FLASCC)/usr/bin/genfs" lessons/$@/fs/ --name=myfs --type=embed lessons/$@/temp/ttt
	# Compile VFS
	# TODO
	$(ASC2) -AS3 -optimize -strict \
	-import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/BinaryData.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/ISpecialFile.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/IBackingStore.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/IVFS.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/InMemoryBackingStore.abc) \
	-import $(call nativepath,$(FLASCC)/usr/lib/PlayerKernel.abc) \
	lessons/$@/temp/ttt*.as -outdir lessons/$@/ -out myfs
	# Generate Console.ABC
	$(ASC2) -AS3 -optimize -strict \
		-import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) \
		-import $(call nativepath,$(GLS3D)/install/usr/lib/libGL.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/ISpecialFile.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/IBackingStore.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/IVFS.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/InMemoryBackingStore.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/AlcVFSZip.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/CModule.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/C_Run.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/BinaryData.abc) \
		-import $(call nativepath,$(FLASCC)/usr/lib/PlayerKernel.abc) \
		-import $(call nativepath,lessons/$@/myfs.abc) \
		Console.as -outdir lessons/$@/ -out Console 
	# Generate Obj
	#"$(FLASCC)/usr/bin/g++" -O4 -c lessons/$@/$@.cpp
	#"$(FLASCC)/usr/bin/nm" $@.o | grep " T " | awk '{print $$3}' | sed 's/__/_/' >> exports-$@.txt 
	# Generate Main.SWF
	"$(FLASCC)/usr/bin/g++" $(BASE_CFLAGS) $(wildcard lessons/$@/*.cpp) $(GLS3D)/install/usr/lib/libGL.abc lessons/$@/myfs.abc -symbol-abc=lessons/$@/Console.abc \
		-I$(GLS3D)/install/usr/include/ -L$(GLS3D)/install/usr/lib/ \
		-I$(FLASCC)/../samples/Example_freeglut/install/usr/include/ -L$(FLASCC)/../samples/Example_freeglut/install/usr/lib/ \
		-lSDL -lSDL_image -lSDL_mixer -lSDL_ttf -lglut -lGL -lvgl -lfreetype -lvorbis -logg -lwebp -ltiff -lpng -lz -ljpeg -lm  \
		-emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -o $@.swf 

include Makefile.common
  
clean:
	@rm -rf *.swf **/*.swc **/*.bc **/*.abc **/*.exe **/*.zip
