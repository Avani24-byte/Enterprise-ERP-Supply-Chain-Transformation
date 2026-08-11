import KpiChart from "../components/KpiChart";

const turnoverData = [
  { name: "Jan", value: 4.2 },
  { name: "Feb", value: 4.8 },
  { name: "Mar", value: 5.1 },
  { name: "Apr", value: 4.6 },
];

const otifData = [
  { name: "Jan", value: 88 },
  { name: "Feb", value: 91 },
  { name: "Mar", value: 85 },
  { name: "Apr", value: 93 },
];

const leadTimeData = [
  { name: "Jan", value: 12 },
  { name: "Feb", value: 10 },
  { name: "Mar", value: 14 },
  { name: "Apr", value: 9 },
];

export default function Inventory() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold text-gray-800">Inventory Overview</h1>
      <p className="text-gray-500 mt-2 mb-6">
        Inventory data and KPIs will appear here.
      </p>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <KpiChart
          title="Inventory Turnover"
          data={turnoverData}
          dataKey="value"
          color="#2563eb"
        />
        <KpiChart
          title="OTIF %"
          data={otifData}
          dataKey="value"
          color="#16a34a"
        />
        <KpiChart
          title="Lead Time (days)"
          data={leadTimeData}
          dataKey="value"
          color="#dc2626"
        />
      </div>
    </div>
  );
}
