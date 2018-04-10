require 'salesforce/einstein/base'

module Salesforce
  module Einstein
    module V2
      class LanguageClient < Salesforce::Einstein::Base

        def predict_for_intent(document: , model_id: 'CommunitySentiment', num_results: nil, sample_id: nil)
          post '/language/intent', { document: document, modelId: model_id, numResults: num_results, sampleId: sample_id }
        end

        def predict_for_sentiment(document: , model_id: 'CommunitySentiment', num_results: nil, sample_id: nil)
          post '/language/sentiment', { document: document, modelId: model_id, numResults: num_results, sampleId: sample_id }
        end

        def create_dataset(name, labels, type = 'image')
          post '/language/datasets', { type: type, name: name, labels: labels }
        end

        def create_dataset_from_file(sync: true, data: nil, name: nil, path: nil, type: 'text-intent')
          params = { name: name, type: type }
          params[:data] = data if data
          params[:path] = path if path
          post "/language/datasets/upload#{sync ? '/sync' : ''}", params
        end

        def get_all_datasets
          get '/language/datasets'
        end

        def get_dataset(dataset_id)
          get "/language/datasets/#{dataset_id}"
        end

        def delete_dataset(dataset_id)
          delete "/language/datasets/#{dataset_id}"
        end

        def get_deletion_status(deletion_id)
          get "/language/deletion/#{deletion_id}"
        end

        def create_label(dataset_id, name)
          post "/language/datasets/#{dataset_id}/labels", name: name
        end

        def get_label(dataset_id, label_id)
          get "/language/datasets/#{dataset_id}/labels/#{label_id}"
        end

        def create_example(dataset_id, params)
          post "/language/datasets/#{dataset_id}/examples", params
        end

        def get_all_examples(dataset_id)
          get "/language/datasets/#{dataset_id}/examples"
        end

        def get_all_examples_for_label(dataset_id, label_id)
          get "/language/datasets/#{dataset_id}/examples?labelId=#{label_id}"
        end

        def delete_example(dataset_id, example_id)
          delete "/language/datasets/#{dataset_id}/examples/#{example_id}"
        end

        def train_dataset(dataset_id: , name: )
          post '/language/train', { datasetId: dataset_id, name: name }
        end

        def retain_dataset(params)
          post "/language/retrain", params
        end

        def get_training_status(model_id)
          get "/language/train/#{model_id}"
        end

        def get_model_metrics(model_id)
          get "/language/models/#{model_id}"
        end

        def get_all_models(dataset_id)
          get "/language/datasets/#{dataset_id}/models"
        end
      end
    end

    LanguageClient = V2::LanguageClient
  end
end

