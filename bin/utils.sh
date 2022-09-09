function assertCurrentDirectory() {
	current_dir=$(basename $(pwd))
	if [ "$current_dir" != "balena-sound" ]; then
		echo "Must be ran from repo root, but currently in directory: $current_dir"
		exit 1
	fi
}
