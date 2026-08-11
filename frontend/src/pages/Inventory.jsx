import { useEffect, useState } from "react";
import KpiChart from "../components/KpiChart";
import { getInventory } from "../api/inventoryApi";

// Mock data used as fallback if the API isn't ready yet
const mockData = {
  turnover: [
    { name: "Jan", value: 4.2 },
    { name: "Feb", value: 4.8 },
    { name: "Mar", value: 5.1 },
    { name: "Apr", value: 4.6 },
  ],
  otif: [
    { name: "Jan", value: 88 },
    { name: "Feb", value: 91 },
    { name: "Mar", value: 85 },
    { name: "Apr", value: 93 },
  ],
  leadTime: [
    { name: "Jan", value: 12 },
    { name: "Feb", value: 10 },
    { name: "Mar", value: 14 },
    { name: "Apr", value: 9 },
  ],
};

export default function Inventory() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [usingMock, setUsingMock] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const result = await getInventory();
        setData(result);
        setUsingMock(false);
        setError(null);
      } catch (err) {
        // API not ready or failed — fall back to mock data instead of breaking the UI
        console.warn(
          "Inventory API not available, using mock data:",
          err.message
        );
        setData(mockData);
        setUsingMock(true);
        setError(null);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">Inventory Overview</h1>
      <p className="text-gray-500 mt-2 mb-2">
        Inventory data and KPIs will appear here.
      </p>

      {usingMock && !loading && (
        <p className="text-amber-600 text-xs mb-4">
          ⚠ Showing sample data — live API not connected yet.
        </p>
      )}

      {loading && (
        <p className="text-gray-500 text-sm">Loading inventory data...</p>
      )}

      {!loading && (!data || data.length === 0) && (
        <p className="text-gray-500 text-sm">
          No inventory data available yet.
        </p>
      )}

      {!loading && data && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <KpiChart
            title="Inventory Turnover"
            data={data.turnover}
            dataKey="value"
            color="#2563eb"
          />
          <KpiChart
            title="OTIF %"
            data={data.otif}
            dataKey="value"
            color="#16a34a"
          />
          <KpiChart
            title="Lead Time (days)"
            data={data.leadTime}
            dataKey="value"
            color="#dc2626"
          />
        </div>
      )}
    </div>
  );
}
