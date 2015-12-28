

context = ChefDK::Generator.context
app_dir = File.join(context.app_root, context.app_name)
cookbooks_dir = context.cookbook_root
cookbook_dir = File.join(cookbooks_dir, context.cookbook_name)
cookbook_dir = File.join(cookbooks_dir, context.app_name)
hooks_dir = File.join(cookbook_dir, '/hooks')

# app root dir
directory app_dir

# TK
template "#{app_dir}/.kitchen.yml" do
  source 'kitchen.yml.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end

# README
template "#{app_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
end

# Generated Cookbook:

# cookbook collection dir
directory cookbooks_dir

# cookbook collection dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

# Berks
cookbook_file "#{cookbook_dir}/Berksfile"

# Recipes

directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source 'default_recipe.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end

# Attributes

directory "#{cookbook_dir}/attributes"

template "#{cookbook_dir}/attributes/default.rb" do
  source 'default_attribute.rb.erb'
  helpers(ChefDK::Generator::TemplateHelper)
end

# git
if context.have_git
  unless context.skip_git_init

    execute('initialize-git') do
      command('git init .')
      cwd cookbook_dir
    end

    cookbook_file "#{cookbook_dir}/.gitignore" do
      source 'gitignore'
    end

    link "#{cookbook_dir}/.git/hooks/pre-commit" do
      to "#{hooks_dir}/pre-commit"
      link_type :symbolic
    end

    execute 'update pre-commit execute permissions' do
      command "chmod +x #{cookbook_dir}/.git/hooks/pre-commit"
      action :run
    end
  end
end
