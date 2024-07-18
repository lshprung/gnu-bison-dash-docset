SRC_ICON_FILE=$(SOURCE_DIR)/icon.png

MANUAL_URL  = https://www.gnu.org/software/bison/manual/bison.html_node.tar.gz
MANUAL_FILE = tmp/bison.html_node.tar.gz

$(MANUAL_FILE): tmp
	curl -o $@ $(MANUAL_URL)

$(DOCUMENTS_DIR): $(RESOURCES_DIR) $(MANUAL_FILE)
	mkdir -p $@
	tar -x -z -f $(MANUAL_FILE) -C $@

$(INDEX_FILE): $(SOURCE_DIR)/src/index-pages.sh $(SCRIPTS_DIR)/gnu/index-terms-colon.sh $(DOCUMENTS_DIR)
	rm -f $@
	$(SOURCE_DIR)/src/index-pages.sh $@ $(DOCUMENTS_DIR)/*.html
	$(SCRIPTS_DIR)/gnu/index-terms-colon.sh "Entry" $@ $(DOCUMENTS_DIR)/Index-of-Terms.html
