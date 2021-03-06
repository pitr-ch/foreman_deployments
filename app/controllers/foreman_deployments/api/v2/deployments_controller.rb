module ForemanDeployments
  module Api
    module V2
      class DeploymentsController < ForemanDeployments::Api::V2::BaseController

        include ::Api::Version2
        include ::Api::TaxonomyScope

        resource_description do
          name 'Deployment'
          # FIXME fix apipie if moved to BaseController it will assign foreman_deployments to everything
          api_base_url '/foreman_deployments/api'
        end

        before_filter :find_optional_nested_object
        before_filter :find_resource, :only => %w{show update destroy}


        api :GET, "/deployments/", N_("List all deployments")
        api :GET, "/locations/:location_id/deployments", N_("List of deployments per location")
        api :GET, "/organizations/:organization_id/deployments", N_("List of deployments per organization")
        param_group :taxonomy_scope, ::Api::V2::BaseController
        param_group :search_and_pagination, ::Api::V2::BaseController

        def index
          @deployments = resource_scope_for_index
        end

        api :GET, "/deployments/:id/", N_("Show a deployment")
        param :id, :identifier, :required => true

        def show
        end

        def_param_group :deployment do
          param :deployment, Hash, :required => true, :action_aware => true do
            param :name, String, :required => true
            param :description, String
            param_group :taxonomies, ::Api::V2::BaseController
            param :stack_id, Integer, :desc => N_('ID of stack to be deployed')
          end
        end

        api :POST, "/deployments/", N_("Create a deployment")
        param_group :deployment, :as => :create

        def create
          # TODO is there a better way pattern?
          @deployment = Deployment.new(
              params[:deployment].
                  reject { |k, _| k == 'stack_id' }.
                  merge(stack: Stack.find(params[:deployment][:stack_id])))
          process_response @deployment.save
        end

        api :PUT, "/deployments/:id/", N_("Update a deployment")
        param :id, :identifier, :required => true
        param_group :deployment

        def update
          process_response @deployment.update_attributes(params[:deployment])
        end

        api :DELETE, "/deployments/:id/", N_("Delete a deployment")
        param :id, :identifier, :required => true

        def destroy
          process_response @deployment.destroy
        end

        private

        def allowed_nested_id
          %w(location_id organization_id)
        end

        def resource_class
          ForemanDeployments::Deployment
        end

      end
    end
  end
end
