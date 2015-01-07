module ForemanDeployments
  module Api
    module V2
      class StacksController < V2::BaseController

        include ::Api::Version2
        include ::Api::TaxonomyScope

        resource_description do
          name 'Stack'
        end

        before_filter :find_optional_nested_object
        before_filter :find_resource, :only => %w{show update destroy}


        api :GET, "/stacks/", N_("List all stacks")
        api :GET, "/locations/:location_id/stacks", N_("List of stacks per location")
        api :GET, "/organizations/:organization_id/stacks", N_("List of stacks per organization")
        param_group :taxonomy_scope, ::Api::V2::BaseController
        param_group :search_and_pagination, ::Api::V2::BaseController

        def index
          @stacks = resource_scope_for_index
        end

        api :GET, "/stacks/:id/", N_("Show a stack")
        param :id, :identifier, :required => true

        def show
        end

        def_param_group :stack do
          param :stack, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true
            param :parent_id, :number, :desc => N_("A parent stack")
            param_group :taxonomies, ::Api::V2::BaseController
          end
        end

        api :POST, "/stacks/", N_("Create a stack")
        param_group :stack, :as => :create

        def create
          @stack = Stack.new(params[:stack])
          process_response @stack.save
        end

        api :PUT, "/stacks/:id/", N_("Update a stack")
        param :id, :identifier, :required => true
        param_group :stack

        def update
          process_response @stack.update_attributes(params[:stack])
        end

        api :DELETE, "/stacks/:id/", N_("Delete a stack")
        param :id, :identifier, :required => true

        def destroy
          process_response @stack.destroy
        end

        private

        def allowed_nested_id
          %w(location_id organization_id)
        end

        def resource_class
          ForemanDeployments::Stack
        end

      end
    end
  end
end
