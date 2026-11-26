function fig = plot_RN(ellValues, hatValues, outputFile, visibility)
% PLOT_RN  Paper spectrum: ell=2,3 and hat_n=0,...,41 only.
% Global plot:             plot_RN
% All overtones at ell=3:   plot_RN(3)
% One overtone at ell=2:    plot_RN(2,8)
% One overtone, both ell:   plot_RN([2 3],8)
% Selected overtones:      plot_RN(3,[22 23])
% Save a plot:             plot_RN(2,8,'overtone8.pdf')
% Reads the sibling RN_spectrum.xlsx, sheets hat_n_00,...,hat_n_41.
% Columns: ell,hat_n,Q,omega_re,omega_im. Units G=c=M=1; exp(-i*omega*t).
% XLSX preserves decimal text; doubles are only for visualization.
% All saved points are retained and connected in charge order. Points and
% lines match the same Q colorbar. Only the 75 finite-damping Q=1 endpoints
% of these families are included; zero-frequency limits are not Q=1 roots.
% No files are written unless outputFile is supplied.
if nargin < 1 || isempty(ellValues), ellValues = [2 3]; end
if nargin < 2, hatValues = []; end
if nargin < 3, outputFile = ''; end
if nargin < 4, visibility = 'on'; end
assert(all(ismember(ellValues,[2 3])),'ell must be 2 or 3');
assert(all(ismember(hatValues,0:41)),'hat_n must lie in 0,...,41');
ellValues = unique(ellValues,'stable');
xlsxFile = fullfile(fileparts(mfilename('fullpath')),'RN_spectrum.xlsx');
if isempty(hatValues)
    selectedSheets = compose("hat_n_%02d",0:41);
else
    selectedSheets = compose("hat_n_%02d",unique(hatValues,'stable'));
end
rows = cell(0,5);
for sheetName = selectedSheets(:)'
    block = readcell(xlsxFile,'Sheet',sheetName);
    rows = [rows; block(2:end,1:5)]; %#ok<AGROW>
end
values = string(rows);
ell = str2double(values(:,1)); hat = str2double(values(:,2));
q = str2double(values(:,3)); wr = str2double(values(:,4)); damping = -str2double(values(:,5));
assert(all(ismember(ell,[2 3]) & ismember(hat,0:41)), ...
    'Workbook contains a root outside the paper indexed families');
keep = ismember(ell,ellValues);
if ~isempty(hatValues), keep = keep & ismember(hat,hatValues); end
assert(any(keep),'No samples match the requested selection');
C = [0.3686 0.3098 0.6353;0.2536 0.4588 0.7059;
 0.2641 0.6091 0.7098;0.4000 0.7608 0.6471;
 0.5804 0.8314 0.6444;0.7477 0.8980 0.6275;
 0.9020 0.9608 0.5961;0.9673 0.9869 0.6980;
 0.9987 0.9595 0.6810;0.9961 0.8784 0.5451;
 0.9935 0.7477 0.4353;0.9804 0.5974 0.3412;
 0.9569 0.4275 0.2627;0.8758 0.3046 0.2941;
 0.7634 0.1634 0.2928;0.6196 0.0039 0.2588];
fig = figure('Color','w','Visible',visibility,'Position',[80 80 610*numel(ellValues) 800]);
tl = tiledlayout(fig,1,numel(ellValues),'TileSpacing','compact','Padding','compact');
for panel = 1:numel(ellValues)
    ax = nexttile(tl); hold(ax,'on');
    mask = keep & ell == ellValues(panel);
    ns = unique(hat(mask & ~isnan(hat)));
    for n = ns(:)'
        idx = find(mask & hat == n);
        [~,ord] = sortrows([q(idx),idx],[1 2]); idx = idx(ord);
        pts = [q(idx),wr(idx),damping(idx)];
        drawChargeLine(ax,pts,C);
        if numel(ns) <= 8
            text(ax,pts(1,2),pts(1,3),sprintf('  $\\hat n=%d$',n), ...
                'Interpreter','latex','FontSize',10,'VerticalAlignment','bottom');
        end
    end
    sub = mask & q < 1; ext = mask & q == 1;
    scatter(ax,wr(sub),damping(sub),5,q(sub),'filled', ...
        'MarkerEdgeColor','none','Tag','saved-subextremal');
    if any(ext)
        scatter(ax,wr(ext),damping(ext),55,q(ext),'p','filled', ...
            'MarkerEdgeColor','k','LineWidth',.4,'Tag','saved-extremal');
    end
    xline(ax,0,'--','Color',[.55 .55 .55],'LineWidth',.65);
    colormap(ax,C); clim(ax,[0 1]);
    cb = colorbar(ax); cb.Label.String = '$Q$'; cb.Label.Interpreter = 'latex';
    cb.Ticks = 0:.2:1;
    xlabel(ax,'$\Re(\omega)$','Interpreter','latex','FontSize',13);
    ylabel(ax,'$-\Im(\omega)$','Interpreter','latex','FontSize',13);
    title(ax,sprintf('$\\ell=%d$',ellValues(panel)),'Interpreter','latex','FontSize',14);
    ax.FontName = 'Times New Roman'; ax.FontSize = 11;
    grid(ax,'on'); box(ax,'on'); ax.GridAlpha = .15;
    axis(ax,'padded');
end
fprintf('Plotted %d saved samples, including %d Q=1 roots.\n',sum(keep),sum(keep & q==1));
if ~isempty(outputFile)
    [~,~,ext] = fileparts(outputFile);
    if strcmpi(ext,'.pdf'),exportgraphics(fig,outputFile,'ContentType','vector');
    else,exportgraphics(fig,outputFile,'Resolution',220);end
end
end

function drawChargeLine(ax,p,C)
% Split drawn segments only at Q-bin boundaries; data points are unchanged.
if size(p,1)<2, return; end
qa=p(1:end-1,1); qb=p(2:end,1); dq=qb-qa;
assert(all(dq>=0),'Charge order is not monotone');
a=p(1:end-1,2:3); b=p(2:end,2:3);
bin=min(16,max(1,floor(qa*16)+1));
for k=1:16
    lo=max(qa,(k-1)/16); hi=min(qb,k/16);
    duplicate=(dq==0 & bin==k);
    valid=(hi>lo & dq>0) | duplicate;
    if ~any(valid),continue;end
    denom=dq(valid); isdup=denom==0; denom(isdup)=1;
    t0=(lo(valid)-qa(valid))./denom; t1=(hi(valid)-qa(valid))./denom;
    t0(isdup)=0;t1(isdup)=1;
    left=a(valid,:)+t0.*(b(valid,:)-a(valid,:));
    right=a(valid,:)+t1.*(b(valid,:)-a(valid,:));
    x=reshape([left(:,1),right(:,1),nan(sum(valid),1)]',[],1);
    y=reshape([left(:,2),right(:,2),nan(sum(valid),1)]',[],1);
    line(ax,x,y,'Color',C(k,:),'LineWidth',.7,'HandleVisibility','off','Tag','Q-colored-line');
end
end
