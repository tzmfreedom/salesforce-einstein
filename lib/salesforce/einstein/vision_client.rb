# frozen_string_literal: true

require 'salesforce/einstein/base'

module Salesforce
  module Einstein
    module V2
      class VisionClient < Salesforce::Einstein::Base
        def predict_with_url(url, modelId = 'GeneralImageClassifier')
          post '/vision/predict', sampleLocation: url, modelId: modelId
        end

        # def predict_with_file path, modelId = 'GeneralImageClassifier'
        #   post '/predict', {sampleContent: path, modelId: modelId}
        # end

        def predict_with_base64(base64_string, modelId = 'GeneralImageClassifier')
          post '/vision/predict', sampleBase64Content: base64_string, modelId: modelId
        end

        def create_dataset(name, labels, type = 'image')
          post '/vision/datasets', type: type, name: name, labels: labels
        end

        def all_datasets
          get '/vision/datasets'
        end

        def dataset(dataset_id)
          get "/vision/datasets/#{dataset_id}"
        end

        def delete_dataset(dataset_id)
          delete "/vision/datasets/#{dataset_id}"
        end

        def deletion_status(deletion_id)
          get "/vision/deletion/#{deletion_id}"
        end

        def create_label(dataset_id, name)
          post "/vision/datasets/#{dataset_id}/labels", name: name
        end

        def label(dataset_id, label_id)
          get "/vision/datasets/#{dataset_id}/labels/#{label_id}"
        end

        def create_example(dataset_id, params)
          post "/vision/datasets/#{dataset_id}/examples", params
        end

        def all_examples(dataset_id)
          get "/vision/datasets/#{dataset_id}/examples"
        end

        def all_examples_for_label(dataset_id, label_id)
          get "/vision/datasets/#{dataset_id}/examples?labelId=#{label_id}"
        end

        def delete_example(dataset_id, example_id)
          delete "/vision/datasets/#{dataset_id}/examples/#{example_id}"
        end

        def train_dataset(params)
          post '/vision/train', params
        end

        def retain_dataset(params)
          post '/vision/retrain', params
        end

        def training_status(model_id)
          get "/vision/train/#{model_id}"
        end

        def model_metrics(model_id)
          get "/vision/models/#{model_id}"
        end

        def all_models(dataset_id)
          get "/datasets/#{dataset_id}/models"
        end
      end
    end

    VisionClient = V2::VisionClient
  end
end
