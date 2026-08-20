import { supabase } from './supabaseClient';

export async function fetchAllBaselineProducts() {
  try {
    const { data, error } = await supabase.from('baseline_products').select('*');
    if (error) throw error;
    if (!data || data.length === 0) return null;

    return data.map(row => ({
      id: row.id,
      vendor: row.vendor,
      itemCode: row.item_code,
      componentName: row.component_name,
      model: row.model,
      approvedRm: row.approved_rm,
      approvedRmRate: Number(row.approved_rm_rate),
      masterbatchPct: Number(row.masterbatch_pct),
      masterbatchRate: Number(row.masterbatch_rate),
      cavity: Number(row.cavity),
      netWeight: Number(row.net_weight),
      runnerWeight: Number(row.runner_weight),
      cycleTimeApproved: Number(row.cycle_time_approved),
      cycleTime: Number(row.cycle_time),
      machineTonnage: Number(row.machine_tonnage),
      shiftTariff: Number(row.shift_tariff),
      bopCost: Number(row.bop_cost),
      postOpCost: Number(row.post_op_cost || 0),
      parameters: row.parameters || {}
    }));
  } catch (err) {
    console.warn('Supabase fetch products error, fallback to local store:', err.message);
    return null;
  }
}

export async function saveBaselineProductToSupabase(product) {
  try {
    const record = {
      id: product.id || `prod-${product.itemCode}`,
      vendor: product.vendor,
      item_code: product.itemCode,
      component_name: product.componentName,
      model: product.model || '',
      approved_rm: product.approvedRm || '',
      approved_rm_rate: Number(product.approvedRmRate || 0),
      masterbatch_pct: Number(product.masterbatchPct || 0),
      masterbatch_rate: Number(product.masterbatchRate || 0),
      cavity: Number(product.cavity || 1),
      net_weight: Number(product.netWeight || 0),
      runner_weight: Number(product.runnerWeight || 0),
      cycle_time_approved: Number(product.cycleTimeApproved || 0),
      cycle_time: Number(product.cycleTime || 0),
      machine_tonnage: Number(product.machineTonnage || 0),
      shift_tariff: Number(product.shiftTariff || 0),
      bop_cost: Number(product.bopCost || 0),
      post_op_cost: Number(product.postOpCost || 0),
      parameters: product.parameters || {}
    };

    const { error } = await supabase.from('baseline_products').upsert(record, { onConflict: 'item_code' });
    if (error) throw error;
  } catch (err) {
    console.error('Failed to sync product to Supabase:', err.message);
  }
}

export async function fetchRmMappingsFromSupabase() {
  try {
    const { data, error } = await supabase.from('rm_mappings').select('*');
    if (error) throw error;
    if (!data || data.length === 0) return null;

    return data.map(r => ({
      id: r.id,
      vendor: r.vendor,
      periodFrom: r.period_from,
      periodTo: r.period_to,
      type: r.type,
      approvedCode: r.approved_code,
      approvedPrice: Number(r.approved_price),
      alt1Code: r.alt1_code,
      alt1Price: Number(r.alt1_price),
      alt2Code: r.alt2_code,
      alt2Price: Number(r.alt2_price),
      alt3Code: r.alt3_code,
      alt3Price: Number(r.alt3_price),
      activeAlt: r.active_alt || 'alt1'
    }));
  } catch (err) {
    console.warn('Supabase fetch RM mappings error:', err.message);
    return null;
  }
}

export async function saveRmMappingToSupabase(mapping) {
  try {
    const record = {
      id: mapping.id,
      vendor: mapping.vendor,
      period_from: mapping.periodFrom || '2026-08-01',
      period_to: mapping.periodTo || '2026-08-31',
      type: mapping.type,
      approved_code: mapping.approvedCode,
      approved_price: Number(mapping.approvedPrice || 0),
      alt1_code: mapping.alt1Code || '',
      alt1_price: Number(mapping.alt1Price || 0),
      alt2_code: mapping.alt2Code || '',
      alt2_price: Number(mapping.alt2Price || 0),
      alt3_code: mapping.alt3Code || '',
      alt3_price: Number(mapping.alt3Price || 0),
      active_alt: mapping.activeAlt || 'alt1'
    };

    const { error } = await supabase.from('rm_mappings').upsert(record, { onConflict: 'id' });
    if (error) throw error;
  } catch (err) {
    console.error('Failed to sync RM mapping to Supabase:', err.message);
  }
}

export async function fetchSalesFromSupabase() {
  try {
    const { data, error } = await supabase.from('sales_dispatches').select('*');
    if (error) throw error;
    if (!data || data.length === 0) return null;
    return data.map(s => ({
      id: s.id,
      date: s.date,
      itemCode: s.item_code,
      componentName: s.component_name,
      vendor: s.vendor,
      qty: Number(s.qty),
      sellingPrice: Number(s.selling_price)
    }));
  } catch (err) {
    return null;
  }
}

export async function saveSalesDispatchToSupabase(dispatch) {
  try {
    const record = {
      id: dispatch.id || `disp-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      date: dispatch.date,
      item_code: dispatch.itemCode,
      component_name: dispatch.componentName || '',
      vendor: dispatch.vendor,
      qty: Number(dispatch.qty || 0),
      selling_price: Number(dispatch.sellingPrice || 0)
    };
    await supabase.from('sales_dispatches').upsert(record);
  } catch (err) {
    console.error('Failed to sync sales dispatch:', err.message);
  }
}

export async function saveChangeLogToSupabase(log) {
  try {
    const record = {
      id: log.id || `log-${Date.now()}`,
      user_name: log.user || log.authorizedBy || 'System User',
      module: log.module || 'Baseline Master',
      entity: log.entity || log.partCode || 'General',
      change_type: log.changeType || 'Parameter Edit',
      previous_value: String(log.previousValue || ''),
      new_value: String(log.newValue || log.modifications || ''),
      reason: log.reason || ''
    };
    await supabase.from('change_logs').insert(record);
  } catch (err) {
    console.error('Failed to sync change log:', err.message);
  }
}
