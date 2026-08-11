import PurchaseOrderForm from "../components/PurchaseOrderForm";
import VendorForm from "../components/VendorForm";

export default function Procurement() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">
        Procurement / PO Tracking
      </h1>
      <p className="text-gray-500 mt-2 mb-6">
        Purchase orders and procurement status will appear here.
      </p>

      <div className="flex flex-col gap-6">
        <PurchaseOrderForm />
        <VendorForm />
      </div>
    </div>
  );
}
