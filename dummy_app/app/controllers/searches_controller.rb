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

  private

  def extract_pdf_urls(results)
    results.web_results
           .select { |r| r[:url]&.end_with?(".pdf") }
           .map { |r| r[:url] }
           .first(3)
  end
end