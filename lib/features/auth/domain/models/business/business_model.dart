import 'package:duxbe/features/branch/branch.dart';
import 'package:duxbe/shared/shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_model.freezed.dart';
part 'business_model.g.dart';

enum BusinessType { retail, automotive, foodAndBeverage, others }

enum SubscriptionStatus { active, inactive, expired, cancelled }

// create table
//   public.businesses (
//     business_id uuid not null default gen_random_uuid (),
//     name text not null,
//     org_id uuid not null,
//     created_at timestamp with time zone not null default now(),
//     created_by uuid null default auth.uid (),
//     subscription_status public.subscription_status not null default 'inactive'::subscription_status,
//     last_active_at timestamp with time zone null,
//     contact_email text null,
//     contact_phone text null,
//     contact_address text null,
//     currency jsonb null,
//     logo text null,
//     images text[] null,
//     store_name text null,
//     gst_in text null,
//     state text null,
//     country text null,
//     time_zone text null,
//     fiscal_id uuid not null default '00000000-0000-0000-0000-000000000002'::uuid,
//     is_gst_registered boolean null,
//     legal_business_name text null,
//     gst_registered_date boolean not null default false,
//     trade_name text null,
//     composition_scheme boolean not null default false,
//     reverse_charge boolean not null default false,
//     print_on_sale boolean not null default true,
//     print_on_purchase boolean not null default true,
//     allow_walkin_customer boolean not null default false,
//     allow_sales_when_outofstock boolean not null default false,
//     constraint businesses_pkey primary key (business_id),
//     constraint businesses_created_by_fkey foreign key (created_by) references employees (employee_id) on update cascade on delete set null,
//     constraint businesses_fiscal_id_fkey foreign key (fiscal_id) references fiscal_years (fiscal_id) on update cascade on delete set null,
//     constraint businesses_org_id_fkey foreign key (org_id) references organizations (org_id) on update cascade on delete cascade
//   ) tablespace pg_default;

extension BusinessTypeX on BusinessType {
  String get title => switch (this) {
        BusinessType.retail => 'Retail & Service Businesses',
        BusinessType.automotive => 'Automotive',
        BusinessType.foodAndBeverage => 'Food & Beverage',
        BusinessType.others => 'Others',
      };
}

@freezed
class Business with _$Business {
  const factory Business({
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'business_type') required BusinessType businessType,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'fiscal_id') required String fiscalId,
    @JsonKey(name: 'last_active_at') DateTime? lastActiveAt,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'contact_address') String? contactAddress,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'currency') Currency? currency,
    @JsonKey(name: 'images') List<String>? images,
    @JsonKey(name: 'store_name') String? storeName,
    @JsonKey(name: 'gst_in') String? gstIn,
    @JsonKey(name: 'state') String? state,
    @JsonKey(name: 'country') String? country,
    @JsonKey(name: 'time_zone') String? timeZone,
    @JsonKey(name: 'is_gst_registered') bool? isGstRegistered,
    @JsonKey(name: 'legal_business_name') String? legalBusinessName,
    @JsonKey(name: 'gst_registered_date') DateTime? gstRegisteredDate,
    @JsonKey(name: 'trade_name') String? tradeName,
    @JsonKey(name: 'print_on_sale') bool? printOnSale,
    @JsonKey(name: 'print_on_purchase') bool? printOnPurchase,
    @JsonKey(name: 'print_barcode_on_purchase') bool? printBarcodeOnPurchase,
    @JsonKey(name: 'format') PrintFormats? format,
    @JsonKey(name: 'allow_walkin_customer') bool? allowWalkinCustomer,
    @JsonKey(name: 'allow_sales_when_outofstock') bool? allowSalesWhenOutOfStock,
    @JsonKey(name: 'whatsapp_integration', includeToJson: false) WhatsappIntegration? whatsappIntegration,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);
}
