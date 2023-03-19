#!/usr/bin/env sh

create_table() {
	sqlite3 "$DB_PATH" "CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
	sqlite3 "$DB_PATH" "CREATE UNIQUE INDEX IF NOT EXISTS anchor ON searchIndex (name, type, path);"
}

get_title() {
	FILE="$1"

	pup -p -f "$FILE" 'title text{}' | \
		sed 's/(Bison.*)//g' | \
		sed 's/\"/\"\"/g'
}

insert() {
	NAME="$1"
	TYPE="$2"
	PAGE_PATH="$3"

	sqlite3 "$DB_PATH" "INSERT INTO searchIndex(name, type, path) VALUES (\"$NAME\",\"$TYPE\",\"$PAGE_PATH\");"
}

insert_term() {
	LINK="$1"
	NAME="$(echo "$LINK" | pup -p 'a text{}' | sed 's/"/\"\"/g' | tr -d \\n)"
	TYPE="Entry"
	PAGE_PATH="$(echo "$LINK" | pup -p 'a attr{href}')"

	insert "$NAME" "$TYPE" "$PAGE_PATH"
}


insert_index_terms() {
	# Get each term from an index page and insert
	while [ -n "$1" ]; do
		grep -Eo "<a href.*></a>:" "$1" | while read -r line; do
			insert_term "$line"
		done

		shift
	done
}


insert_pages() {
	# Get title and insert into table for each html file
	while [ -n "$1" ]; do
		unset PAGE_NAME
		PAGE_NAME="$(get_title "$1")"
		if [ -n "$PAGE_NAME" ]; then
			insert "$PAGE_NAME" "Guide" "$(basename "$1")"
		fi


		shift
	done
}

TYPE="PAGES"

# Check flags
while true; do
	case "$1" in
		-i|--index)
			TYPE="INDEX"
			shift
			;;
		*)
			break
	esac
done

DB_PATH="$1"
shift

create_table
case "$TYPE" in
	PAGES)
		insert_pages "$@"
		;;
	INDEX)
		insert_index_terms "$@"
		;;
esac
