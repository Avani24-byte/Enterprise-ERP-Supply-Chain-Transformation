import { useEffect, useState } from "react";
import PurchaseOrderForm from "../components/PurchaseOrderForm";
import VendorForm from "../components/VendorForm";
import { getProcurement } from "../api/procurementApi";

export default function Procurement() {
  const [procurementData, setProcurementData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProcurement = async () => {
      try {
        setLoading(true);
        const result = await getProcurement();
        setProcurementData(result);
        setError(null);
      } catch (err) {
        console.warn("Procurement API not available yet:", err.message);
        setProcurementData([]);
        setError(null); // stay silent, don't block the forms
      } finally {
        setLoading(false);
      }
    };
    fetchProcurement();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">
        Procurement / PO Tracking
      </h1>
      <p className="text-gray-500 mt-2 mb-6">
        Purchase orders and procurement status will appear here.
      </p>

      {loading && (
        <p className="text-gray-500 text-sm mb-4">
          Loading procurement data...
        </p>
      )}
      {!loading && procurementData.length === 0 && (
        <p className="text-gray-400 text-xs mb-4">
          No existing procurement records yet — add one below.
        </p>
      )}

      <div className="flex flex-col gap-6">
        <PurchaseOrderForm />
        <VendorForm />
      </div>
    </div>
  );
}
