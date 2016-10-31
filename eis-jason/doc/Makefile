TARGET  = eis-jason

html: $(TARGET).tex Makefile
	latex2html  -split 0 -style jason.css \
              -white -image_type=png  \
              -dir html -mkdir  -toc_stars \
              -show_section_numbers -noinfo -address "Jomi F. Hubner" -html_version 3.2,math \
              -no_navigation $(TARGET).tex
	cp html/$(TARGET).html .
	rm -rf html

clean:
	rm -f $(TARGET).ps *.log $(TARGET).aux $(TARGET).out || true
	rm -rf auto || true
	rm -rf *pdf || true
	find . -name *bak -exec rm {} \; || true
	find . -name *~ -exec rm {} \; || true
	rm -rf html

