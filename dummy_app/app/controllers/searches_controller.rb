# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    query = params[:q] || "ruby programming papers filetype:pdf"
    @client = BraveSearch::Client.new
    @results = @client.search(q: query, count: 5)
    
    render json: {
      query: query,
      web_results: @results.web_results.length,
      pdf_urls: extract_pdf_urls(@results)
    }
  end

  def download_pdfs
    query = params[:q] || "ruby programming papers filetype:pdf"
    
    client = BraveSearch::Client.new
    storage = BraveSearch::Storage.for(:hetzner, 
      bucket: "research-papers",
      endpoint: "https://fsn1.your-objectstorage.com"
    )

    downloaded = client.search_and_download_pdfs(
      q: query, 
      count: 3, 
      storage: storage,
      folder: "papers/#{Date.today}"
    ) do |completed, total|
      puts "Downloaded #{completed}/#{total} PDFs"
    end

    render json: {
      query: query,
      downloaded: downloaded.length,
      files: downloaded.map { |d| d[:key] }
    }
  rescue StandardError => e
    render json: { error: e.message }, status: 422
  end

  def export
    query = params[:q] || "ruby programming"
    format = params[:format] || "json"
    
    client = BraveSearch::Client.new
    
    if params[:async]
      storage_config = {
        provider: :hetzner,
        options: {
          bucket: "research-exports", 
          endpoint: "https://fsn1.your-objectstorage.com"
        }
      }
      
      key = "exports/#{Date.today}/#{SecureRandom.hex(8)}.#{format}"
      job = client.search_and_export_async(
        q: query,
        format: format,
        storage_config: storage_config,
        key: key
      )
      
      render json: { job_id: job.job_id, key: key }
    else
      result = client.search_and_export(q: query, format: format.to_sym)
      
      respond_to do |format_type|
        format_type.json { render json: result[:content] }
        format_type.any { send_data result[:content], filename: "search_results.#{format}" }
      end
    end
  rescue StandardError => e
    render json: { error: e.message }, status: 422
  end

  private

  def extract_pdf_urls(results)
    results.web_results
           .select { |r| r[:url]&.end_with?(".pdf") }
           .map { |r| r[:url] }
           .first(3)
  end
end