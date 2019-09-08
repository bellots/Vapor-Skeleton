
    require 'xcodeproj'
    project_name = ARGV[0]
    file_path = ARGV[1]
    destination_folder_string = ARGV[2]
    targets_string = ARGV[3]

    destination_folders = destination_folder_string.split('|')
    target_names = targets_string.split('|')

    project_path = "./#{project_name}.xcodeproj"
    project = Xcodeproj::Project.open(project_path)

    reference = project
    path = "./"
    destination_folders.each do |f|
      path = path + "/" + f
      if reference[f] != nil
        reference = reference[f]
      else
        reference = reference.new_group(f, f, :group)
      end
    end

    file = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(reference , file_path , :group)

    reference << file

    project.targets
            .select { |t| target_names.include?(t.name)}
            .each do |t|
              t.source_build_phase.add_file_reference(file)
            end
    project.save