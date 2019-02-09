require 'spec_helper'

describe Spree::Api::ShipmentsController, type: :controller do
  render_views

  let!(:shipment) { create(:shipment) }
  let!(:attributes) { [:id, :tracking, :number, :cost, :shipped_at, :stock_location_name, :order_id, :shipping_rates, :shipping_method, :inventory_units] }

  before do
    allow(controller).to receive(:spree_current_user) { current_api_user }
  end

  context "as an admin" do
    let!(:order) { shipment.order }
    let(:order_ship_address) { create(:address) }
    let!(:stock_location) { create(:stock_location_with_items) }
    let!(:variant) { create(:variant) }
    let(:params) do
      { quantity: 2,
        variant_id: stock_location.stock_items.first.variant.to_param,
        order_id: order.number,
        stock_location_id: stock_location.to_param,
        format: :json }
    end

    before do
      order.update_attribute(:ship_address_id, order_ship_address.id)
    end

    sign_in_as_admin!

    context '#create' do
      it 'creates a shipment if order does not have a shipment' do
        order.shipment.destroy
        order.reload

        spree_post :create, params

        validate_response
        expect(json_response["inventory_units"].size).to eq 2
        expect(order.reload.line_items.first.variant.price).to eq(variant.price)
      end

      it 'updates and returns exiting shipment, if order already has a shipment' do
        original_shipment_id = order.shipment.id

        spree_post :create, params

        expect(json_response["id"]). to eq(original_shipment_id)
        validate_response
        expect(json_response["inventory_units"].size).to eq 2
        expect(order.reload.line_items.first.variant.price).to eq(variant.price)
      end

      it 'updates existing shipment with variant override if an VO is sent' do
        hub = create(:distributor_enterprise)
        order.update_attribute(:distributor, hub)
        variant_override = create(:variant_override, hub: hub, variant: variant)

        spree_post :create, params

        validate_response
        expect(json_response["inventory_units"].size).to eq 2
        expect(order.reload.line_items.first.price).to eq(variant_override.price)
      end
    end

    context 'for a completed order with shipment' do
      let(:order) { create :completed_order_with_totals }

      before { params[:id] = order.shipments.first.to_param }

      it 'adds a variant to the shipment' do
        spree_put :add, params

        validate_response
        expect(inventory_units_for_variant(json_response["inventory_units"], variant).size).to eq 2
      end

      it 'removes a variant from the shipment' do
        params[:variant_id] = order.line_items.first.variant.to_param
        params[:quantity] = 1

        spree_put :remove, params

        validate_response
        expect(inventory_units_for_variant(json_response["inventory_units"], variant).size).to eq 0
      end

      it 'adds a variant override to the shipment' do
        hub = create(:distributor_enterprise)
        order.update_attribute(:distributor, hub)
        variant_override = create(:variant_override, hub: hub, variant: variant)

        spree_put :add, params

        validate_response
        expect(inventory_units_for_variant(json_response["inventory_units"], variant).size).to eq 2
        expect(order.reload.line_items.last.price).to eq(variant_override.price)
      end

      def inventory_units_for_variant(inventory_units, variant)
        inventory_units.select { |unit| unit['variant_id'] == variant.id }
      end
    end

    def validate_response
      expect(response.status).to eq 200
      attributes.all?{ |attr| json_response.key? attr.to_s }
      expect(json_response["shipping_method"]["name"]).to eq order.shipping_method.name
    end
  end
end
