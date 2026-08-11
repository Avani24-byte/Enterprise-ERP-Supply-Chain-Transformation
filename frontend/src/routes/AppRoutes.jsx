import { Routes, Route } from "react-router-dom";
import Inventory from "../pages/Inventory";
import Procurement from "../pages/Procurement";
import Orders from "../pages/Orders";
import Shipments from "../pages/Shipments";
import DashboardLayout from "../layouts/DashboardLayout";

export default function AppRoutes() {
  return (
    <Routes>
      <Route element={<DashboardLayout />}>
        <Route path="/" element={<Inventory />} />
        <Route path="/procurement" element={<Procurement />} />
        <Route path="/orders" element={<Orders />} />
        <Route path="/shipments" element={<Shipments />} />
      </Route>
    </Routes>
  );
}
