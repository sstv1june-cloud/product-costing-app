import { supabase } from './supabaseClient';

const DEFAULT_INITIAL_PRODUCTS = [
  {
    id: 'prod-atom-1',
    vendor: 'Atomberg',
    item_code: 'A101703',
    component_name: 'Aris Top Canopy- Gloss Black',
    model: 'Aris 1200mm',
    approved_rm: 'PP H110MA',
    approved_rm_rate: 131.00,
    masterbatch_pct: 4.0,
    masterbatch_rate: 250.00,
    cavity: 2,
    net_weight: 37.0,
    runner_weight: 1.0,
    cycle_time_approved: 47.0,
    cycle_time: 47.0,
    machine_tonnage: 200,
    shift_tariff: 2000,
    bop_cost: 0.0,
    post_op_cost: 1.73,
    parameters: {
      runningCavity: 2,
      runningNetWeight: 37.0,
      runningRunnerWeight: 1.0,
      runningCycleTime: 47.0,
      runningTonnage: 200,
      runningMbPct: 4.0,
      runningPostOpCost: 1.73,
      runningBopCost: 0.0
    }
  },
  {
    id: 'prod-atom-2',
    vendor: 'Atomberg',
    item_code: 'A101701',
    component_name: 'Aris Top Canopy- Gloss White',
    model: 'Aris 1200mm',
    approved_rm: 'PP H110MA',
    approved_rm_rate: 131.00,
    masterbatch_pct: 4.0,
    masterbatch_rate: 250.00,
    cavity: 2,
    net_weight: 37.0,
    runner_weight: 1.0,
    cycle_time_approved: 47.0,
    cycle_time: 47.0,
    machine_tonnage: 200,
    shift_tariff: 2000,
    bop_cost: 0.0,
    post_op_cost: 1.73,
    parameters: {
      runningCavity: 2,
      runningNetWeight: 37.0,
      runningRunnerWeight: 1.0,
      runningCycleTime: 47.0,
      runningTonnage: 200,
      runningMbPct: 4.0,
      runningPostOpCost: 1.73,
      runningBopCost: 0.0
    }
  },
  {
    id: 'prod-haier-1',
    vendor: 'Haier',
    item_code: '0060217989D',
    component_name: 'End cap Bottom Ref-ABS-DC-195,220',
    model: 'OLD DC- 195,220',
    approved_rm: 'ABS 300 Pre Colour',
    approved_rm_rate: 136.20,
    masterbatch_pct: 0.0,
    masterbatch_rate: 0.0,
    cavity: 2,
    net_weight: 197.0,
    runner_weight: 40.0,
    cycle_time_approved: 48.0,
    cycle_time: 48.0,
    machine_tonnage: 450,
    shift_tariff: 3600,
    bop_cost: 0.14,
    parameters: {
      runningCavity: 2,
      runningNetWeight: 197.0,
      runningRunnerWeight: 40.0,
      runningCycleTime: 48.0,
      runningTonnage: 450,
      runningMbPct: 0.0,
      runningBopCost: 0.0
    }
  },
  {
    id: 'prod-haier-2',
    vendor: 'Haier',
    item_code: '0060217978E',
    component_name: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX',
    model: 'DC 195, 220',
    approved_rm: 'GPPS SC201LV',
    approved_rm_rate: 100.00,
    masterbatch_pct: 3.5,
    masterbatch_rate: 0.0,
    cavity: 1,
    net_weight: 485.0,
    runner_weight: 22.0,
    cycle_time_approved: 58.0,
    cycle_time: 58.0,
    machine_tonnage: 650,
    shift_tariff: 5760,
    bop_cost: 0.14,
    parameters: {
      runningCavity: 1,
      runningNetWeight: 485.0,
      runningRunnerWeight: 22.0,
      runningCycleTime: 58.0,
      runningTonnage: 650,
      runningMbPct: 3.5,
      runningBopCost: 0.0
    }
  }
];

export async function fetchAllBaselineProducts() {
  try {
    const { data, error } = await supabase.from('baseline_products').select('*');
    if (error) throw error;

    // Seed defaults into database if table is newly connected
    if (!data || data.length < 4) {
      for (const prod of DEFAULT_INITIAL_PRODUCTS) {
        await supabase.from('baseline_products').upsert(prod, { onConflict: 'item_code' });
      }
      const refreshed = await supabase.from('baseline_products').select('*');
      if (refreshed.data && refreshed.data.length > 0) {
        return mapProducts(refreshed.data);
      }
    }

    return mapProducts(data);
  } catch (err) {
    console.warn('Supabase fetch products notice:', err.message);
    return null;
  }
}

function mapProducts(data) {
  return data.map(row => ({
    id: row.id || `prod-${row.item_code}`,
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

    await supabase.from('rm_mappings').upsert(record, { onConflict: 'id' });
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
      user_name: log.user || log.authorizedBy || 'Costing Lead',
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
