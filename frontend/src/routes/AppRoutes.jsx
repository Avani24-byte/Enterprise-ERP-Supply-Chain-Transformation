import { Routes, Route } from "react-router-dom";
import Inventory from "../pages/Inventory";
import Procurement from "../pages/Procurement";
import Orders from "../pages/Orders";
import Shipments from "../pages/Shipments";
import Login from "../pages/Login";
import DashboardLayout from "../layouts/DashboardLayout";
import ProtectedRoute from "./ProtectedRoute";

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route
        element={
          <ProtectedRoute>
            <DashboardLayout />
          </ProtectedRoute>
        }
      >
        <Route path="/" element={<Inventory />} />
        <Route path="/procurement" element={<Procurement />} />
        <Route path="/orders" element={<Orders />} />
        <Route path="/shipments" element={<Shipments />} />
      </Route>
    </Routes>
  );
}
