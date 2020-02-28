# using Plots
using PyPlot
using PyCall
@pyimport matplotlib.patches as patch

# fig_size = (7.,5.1)
fig_size = (6.,4.3)
fig_size1 = (5.5,4.)
label_fontsize = 18-1.5
legend_fontsize = label_fontsize - 3
patterns = ["","."]

label_fontsize1 = label_fontsize
marker_size=6
l_width=1.2
# stride = convert(Int, max_iters/10) +1
stride = 6

colors=["m","b","coral","g","k","r"]
algs = ["PBCD", "Consensus_BCD2", "JP-ADMM", "JP-ADMM_BCD4","IpOpt Solver","Exhaustive Search"]
markers = ["x","o",">","^", "s","."]

folder = string("figs//")

function kappa_finding_sub1(f1)
    global kaps_draw = zeros(3)
    global kaps_draw_idx = zeros(Int32,3)
    # UEs_min = Numb_kaps * ones(NumbDevs, Numb_kaps)
    min_UEs1 = Numb_kaps
    min_UEs2 = 1
    max_UEs  = Numb_kaps

    for n =1:NumbDevs
        UEs_min  = findall(a->abs(a-f_min[n]*1e-9)<1e-3, f1[:,n])
        UEs_max  = findall(a->abs(a-f_max[n]*1e-9)<1e-3, f1[:,n])

        if size(UEs_min)[1] > 0
            min_UEs1 = min(min_UEs1, maximum(UEs_min))
            min_UEs2 = max(min_UEs2, maximum(UEs_min))
        end
        if size(UEs_max)[1] > 0
            max_UEs  = min(max_UEs, minimum(UEs_max))
        end
    end

    kaps_draw[1] = kaps[min_UEs1]
    kaps_draw[2] = kaps[min_UEs2]
    kaps_draw[3] = kaps[max_UEs]
    kaps_draw_idx[1] = min_UEs1
    kaps_draw_idx[2] = min_UEs2
    kaps_draw_idx[3] = max_UEs
    println("kaps_thresh1: ", kaps_draw)
end

function kappa_finding_sub2(p1)
    global kaps_draw2 = zeros(2)
    global kaps_draw_idx2 = zeros(Int32,2)
    # UEs_min = Numb_kaps * ones(NumbDevs, Numb_kaps)
    min_UEs1 = Numb_kaps
    max_UEs  = 1

    for n =1:NumbDevs
        UEs_min  = findall(a->abs(a-Ptx_Min)<1e-4, p1[:,n])
        UEs_max  = findall(a->abs(a-Ptx_Max)<1e-4, p1[:,n])

        if size(UEs_min)[1] > 0
            min_UEs1 = min(min_UEs1, maximum(UEs_min))
        end
        if size(UEs_max)[1] > 0
            max_UEs  = max(max_UEs, minimum(UEs_max))
        end
    end

    kaps_draw2[1] = kaps[min_UEs1]
    kaps_draw2[2] = kaps[max_UEs]
    kaps_draw_idx2[1] = min_UEs1
    kaps_draw_idx2[2] = max_UEs
    println("kaps_thresh2: ", kaps_draw2)
end

function plot_sub1_T(T_cmp, T_cmp1, Tcmp_N1, Tcmp_N2, Tcmp_N3)
    clf()
    cfig = figure(1,figsize=fig_size)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize-1)
    plot(kaps,T_cmp1 .+ 0.02*maximum(T_cmp1),color=colors[6],linestyle="-",linewidth=l_width+0.3,label="\$T_{cmp}^*\$")
    # plot(kaps,T_cmp + 0.02*maximum(T_cmp1),color="gold",linestyle=":",linewidth=l_width+0.3,label="Solver")
    plot(kaps,Tcmp_N1,color=colors[2],linestyle="--",linewidth=l_width+0.2,label="\$T_{\\mathcal{N}_1}\$")
    plot(kaps,Tcmp_N2,color=colors[4],linestyle="-.",linewidth=l_width+0.2,label="\$T_{\\mathcal{N}_2}\$")
    plot(kaps,Tcmp_N3,color=colors[5],linestyle="-",linewidth=l_width+0.2,label="\$T_{\\mathcal{N}_3}\$")

    r1 = patch.Rectangle([0,0],kaps_draw[1],1.05*maximum(T_cmp1), alpha=0.07,fc="k",ec="blue",linewidth=.7)
    r2 = patch.Rectangle([kaps_draw[1],0],kaps_draw[2] - kaps_draw[1],T_cmp1[kaps_draw_idx[1]]+ 0.02*maximum(T_cmp1), alpha=0.12,fc="k",ec="blue",linewidth=.7)
    r3 = patch.Rectangle([kaps_draw[2],0],kaps_draw[3] - kaps_draw[2],T_cmp1[kaps_draw_idx[2]]+ 0.02*maximum(T_cmp1), alpha=0.16,fc="k",ec="blue",linewidth=.7)
    r4 = patch.Rectangle([kaps_draw[3],0],maximum(kaps)- kaps_draw[3],T_cmp1[kaps_draw_idx[3]]+ 0.02*maximum(T_cmp1), alpha=0.2,fc="k",ec="blue",linewidth=.7)
    ax.add_patch(r1)
    ax.add_patch(r2)
    ax.add_patch(r3)
    ax.add_patch(r4)

    annotate("a", xy=[kaps_draw[1]/2;(T_cmp1[1]+0.07*maximum(T_cmp1))], xycoords="data",size=19)
    annotate("b", xy=[kaps_draw[1] + (kaps_draw[2] - kaps_draw[1])/7; (T_cmp1[kaps_draw_idx[1]]+0.04*maximum(T_cmp1))], xycoords="data",size=19)
    annotate("c", xy=[kaps_draw[2] + (kaps_draw[3] - kaps_draw[2])/6;(T_cmp1[kaps_draw_idx[2]]+0.04*maximum(T_cmp1))], xycoords="data",size=19)
    annotate("d", xy=[kaps_draw[3] + (maximum(kaps)- kaps_draw[3])/450;(T_cmp1[kaps_draw_idx[3]]+0.04*maximum(T_cmp1))], xycoords="data",size=19)

    legend(loc="best",fontsize=legend_fontsize+2)
    xlabel("\$\\kappa\$",fontsize=label_fontsize1+2)
    xscale("log")
    ylabel("\$T_{cmp}\$ (sec)",fontsize=label_fontsize1+1)
    xlim(1e-3, 1e1)
    ylim(0, 1.15*T_cmp1[1])
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub1_T.pdf"))
end

function plot_sub1_N(N1, N2, N3)
    clf()
    cfig = figure(2,figsize=fig_size)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize-1)
    # plot(kaps,T_cmp,color=colors[1],linestyle="-",linewidth=l_width,label="Solver")
    step(kaps,N1,color=colors[4],linestyle="-",linewidth=l_width,label="\$\\mathcal{N}_1\$", where="post", marker=markers[2], markersize=marker_size, markevery=5)
    step(kaps,N2,color=colors[3],linestyle="-",linewidth=l_width,label="\$\\mathcal{N}_2\$", where="pre", marker=markers[3], markersize=marker_size, markevery=5)
    step(kaps,N3,color=colors[2],linestyle="-",linewidth=l_width,label="\$\\mathcal{N}_3\$", where="pre", marker=markers[5], markersize=marker_size, markevery=5)

    r1 = patch.Rectangle([0,0],kaps_draw[1],NumbDevs, alpha=0.07,fc="k",ec="blue",linewidth=.7)
    r2 = patch.Rectangle([kaps_draw[1],0],kaps_draw[2] - kaps_draw[1],NumbDevs, alpha=0.12,fc="k",ec="blue",linewidth=.7)
    r3 = patch.Rectangle([kaps_draw[2],0],kaps_draw[3] - kaps_draw[2],NumbDevs, alpha=0.16,fc="k",ec="blue",linewidth=.7)
    r4 = patch.Rectangle([kaps_draw[3],0],maximum(kaps)- kaps_draw[3],NumbDevs, alpha=0.2,fc="k",ec="blue",linewidth=.7)
    ax.add_patch(r1)
    ax.add_patch(r2)
    ax.add_patch(r3)
    ax.add_patch(r4)

    annotate("a", xy=[kaps_draw[1]/2; NumbDevs/2.], xycoords="data",size=19)
    annotate("b", xy=[kaps_draw[1] + (kaps_draw[2] - kaps_draw[1])/13;NumbDevs/2.], xycoords="data",size=19)
    annotate("c", xy=[kaps_draw[2] + (kaps_draw[3] - kaps_draw[2])/6;NumbDevs/2.], xycoords="data",size=19)
    annotate("d", xy=[kaps_draw[3] + (maximum(kaps)- kaps_draw[3])/450;NumbDevs/2.], xycoords="data",size=19)

    legend(loc=1,fontsize=legend_fontsize)
    xlabel("\$\\kappa\$",fontsize=label_fontsize1+2)
    xscale("log")
    xlim(1e-3, 1e1)
    ylabel("Number of elements",fontsize=label_fontsize1+1)
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub1_N.pdf"))
end

function plot_sub1_f(f1)
    kappa_finding_sub1(f1)

    clf()
    cfig = figure(3,figsize=fig_size)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize-1)
    plot(kaps,f_min[1]*ones(Numb_kaps)*1e-9,linestyle=":",color=colors[6])

    if (HETEROGENEOUS == 0) # Homogeneous
        plot(kaps,f_max[1]*ones(Numb_kaps)*1e-9,linestyle="--",color=colors[6])
    end

    for n = 1:5
        if (HETEROGENEOUS > 0)  & (abs(f_max[n]*1e-9 - maximum(f1[:,n])) < 1e-3)
            plot(kaps,f_max[n]*ones(Numb_kaps)*1e-9,linestyle="--",color=colors[n])
            # plot(kaps,f_min[n]*ones(Numb_kaps)*1e-9,linestyle=":",color=colors[n])
        end
        plot(kaps,f1[:,n],color=colors[n],linestyle="-",linewidth=l_width,marker=markers[n], markersize=marker_size-1, markevery=3, label=string("UE ",n))
    end

    r1 = patch.Rectangle([0,0],kaps_draw[1],minimum(f1)+0.1, alpha=0.07,fc="k",ec="blue",linewidth=.7)
    r2 = patch.Rectangle([kaps_draw[1],0],kaps_draw[2] - kaps_draw[1],minimum(f1)+ 0.3, alpha=0.12,fc="k",ec="blue",linewidth=.7)
    r3 = patch.Rectangle([kaps_draw[2],0],kaps_draw[3] - kaps_draw[2],maximum(f1), alpha=0.16,fc="k",ec="blue",linewidth=.7)
    r4 = patch.Rectangle([kaps_draw[3],0],maximum(kaps)- kaps_draw[3],maximum(f1) + 0.15, alpha=0.2,fc="k",ec="blue",linewidth=.7)
    ax.add_patch(r1)
    ax.add_patch(r2)
    ax.add_patch(r3)
    ax.add_patch(r4)

    annotate("a", xy=[kaps_draw[1]/2;(minimum(f1)+0.15)], xycoords="data",size=19)
    annotate("b", xy=[kaps_draw[1] + (kaps_draw[2] - kaps_draw[1])/7;(minimum(f1)+ 0.35)], xycoords="data",size=19)
    annotate("c", xy=[kaps_draw[2] + (kaps_draw[3] - kaps_draw[2])/6;maximum(f1)+ 0.05], xycoords="data",size=19)
    annotate("d", xy=[kaps_draw[3] + (maximum(kaps)- kaps_draw[3])/450;(maximum(f1) + 0.2)], xycoords="data",size=19)

    # axvline(x=kaps_draw[1])
    # axvline(x=kaps_draw[2])
    # axvline(x=kaps_draw[3])

    legend(loc=2,fontsize=legend_fontsize-2)
    xlabel("\$\\kappa\$",fontsize=label_fontsize1+2)
    xscale("log")
    xlim(1e-3, 1e1)
    ylim(0.2,maximum(f1) + 0.35 )
    ylabel("f (GHz)",fontsize=label_fontsize1+1)
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub1_f.pdf"))
end

function plot_sub2_tau(tau1)
    clf()
    cfig = figure(4,figsize=fig_size)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize+1)

    for n = 1:5
        plot(kaps,tau1[:,n], color=colors[n], linestyle="-",linewidth=l_width, marker=markers[n], markersize=marker_size-1, markevery=3, label=string("UE ",n))
    end

    max_tau = maximum(tau1[1,:])

    # r1 = patch.Rectangle([0,0],kaps_draw2[1], 1.1*max_tau, alpha=0.09,fc="k",ec="blue",linewidth=.7)
    # r2 = patch.Rectangle([kaps_draw2[1],0],kaps_draw2[2] - kaps_draw2[1],maximum(tau1[kaps_draw_idx2[1],:]), alpha=0.14,fc="k",ec="blue",linewidth=.7)
    # r3 = patch.Rectangle([kaps_draw2[2],0],maximum(kaps)- kaps_draw2[2],maximum(tau1[kaps_draw_idx2[2],:]), alpha=0.2,fc="k",ec="blue",linewidth=.7)
    # ax.add_patch(r1)
    # ax.add_patch(r2)
    # ax.add_patch(r3)
    #
    # annotate("a", xy=[kaps_draw2[1]/7;(1.1*max_tau)/2], xycoords="data",size=19)
    # annotate("b", xy=[kaps_draw2[1] + (kaps_draw2[2] - kaps_draw2[1])/50;maximum(tau1[kaps_draw_idx2[1],:])/2], xycoords="data",size=19)
    # annotate("c", xy=[kaps_draw2[2] + (maximum(kaps)- kaps_draw2[2])/10;maximum(tau1[kaps_draw_idx2[2],:])/2.5], xycoords="data",size=19)

    legend(loc="best",fontsize=legend_fontsize-1)
    xlabel("\$\\kappa\$",fontsize=label_fontsize1+1)
    # yscale("log")
    xscale("log")
    ylim(0, 1.15*max_tau)
    xlim(1e-3, 1e1)
    ylabel("\$\\tau_n\$ (sec)",fontsize=label_fontsize1+1)
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub2_Tau.pdf"))
end

function plot_sub2_p(p1)
    kappa_finding_sub2(p1)

    clf()
    cfig = figure(5,figsize=fig_size)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize+1)

    plot(kaps,Ptx_Max*ones(Numb_kaps),linestyle=":",color=colors[6])
    plot(kaps,Ptx_Min*ones(Numb_kaps),linestyle=":",color=colors[6])
    for n = 1:5
        plot(kaps,p1[:,n],color=colors[n],linestyle="-",linewidth=l_width, marker=markers[n], markersize=marker_size-1, markevery=3, label=string("UE ",n))
    end

    # r1 = patch.Rectangle([0,0],kaps_draw2[1],minimum(p1)+0.1, alpha=0.09,fc="k",ec="blue",linewidth=.7)
    # r2 = patch.Rectangle([kaps_draw2[1],0],kaps_draw2[2] - kaps_draw2[1],maximum(p1), alpha=0.14,fc="k",ec="blue",linewidth=.7)
    # r3 = patch.Rectangle([kaps_draw2[2],0],maximum(kaps)- kaps_draw2[2],maximum(p1) + 0.1, alpha=0.2,fc="k",ec="blue",linewidth=.7)
    # ax.add_patch(r1)
    # ax.add_patch(r2)
    # ax.add_patch(r3)
    #
    # annotate("a", xy=[kaps_draw2[1]/7;(minimum(p1)+0.1)/1.5], xycoords="data",size=19)
    # annotate("b", xy=[kaps_draw2[1] + (kaps_draw2[2] - kaps_draw2[1])/50;maximum(p1)/2], xycoords="data",size=19)
    # annotate("c", xy=[kaps_draw2[2] + (maximum(kaps)- kaps_draw2[2])/10;(maximum(p1) + 0.1)/2], xycoords="data",size=19)

    legend(loc=2,fontsize=legend_fontsize-1)
    xlabel("\$\\kappa\$",fontsize=label_fontsize1+1)
    xscale("log")
    ylim(0.1,maximum(p1) + 0.15)
    xlim(1e-3, 1e1)
    ylabel("p (Watt)",fontsize=label_fontsize1+1)
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub2_p.pdf"))
end

# function plot_sub3_cvx(Theta1, Obj1, T_cmp1, E_cmp1, T_com1, E_com1)
#     clf()
#     cfig = figure(6,figsize=fig_size1)
#     ax = subplot(1,1,1)
#     ax.tick_params("both",labelsize=legend_fontsize+2)
#
#     x = collect(1.e-5:0.001:0.99)
#     obj   = zeros(size(x)[1])
#     glob_cost_iter = zeros(size(x)[1])
#     glob_numb_iter = zeros(size(x)[1])
#     id = 36
#     println("Convex for kappa: ",  kaps[id])
#     for i=1:size(x)[1]
#         obj[i] = 1/(1 - x[i])* (E_com1[id] - log(x[i])*E_cmp1[id] + kaps[id] * (T_com1[id] - log(x[i])*T_cmp1[id]))
#         glob_cost_iter[i] = E_com1[id] - log(x[i])*E_cmp1[id] + kaps[id] * (T_com1[id] - log(x[i])*T_cmp1[id])
#         glob_numb_iter[i] = 1/(1 - x[i])
#         # obj[i]   = obj_E[i] + obj_T[i]
#     end
#     plot(x, obj,linestyle="-",color="k", label=string("SUB3 Obj: \$\\kappa\$ =", kaps[id]))
#     plot(x, glob_cost_iter,linestyle="--",color=colors[2], label=string("\$E_{glob} + \\kappa * T_{glob}\$"))
#     plot(x, glob_numb_iter,linestyle="--",color=colors[3], label=string("\$ K(\\theta)\$"))
#     # println(x)
#     plot(Theta1[id], Obj1[id],color="r", marker=markers[2], markersize=marker_size)
#
#     legend(loc="best",fontsize=legend_fontsize+6)
#     xlabel("\$\\theta\$",fontsize=label_fontsize1+3)
#     # ylabel("Objective",fontsize=label_fontsize1+1)
#     yscale("log")
#     tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     savefig(string(folder,"Sub3_obj.pdf"))
#     println("Theta: ", minimum(Theta1), " - ", maximum(Theta1))
# end
#
# function plot_sub3_kappa_theta(Theta, d_eta)
#     clf()
#     cfig = figure(10,figsize=fig_size1)
#     ax = subplot(1,1,1)
#     ax.tick_params("both",labelsize=legend_fontsize+3.5)
#     # plot(Numb_devs, Objs_E[:,11],linestyle="--",color=colors[1],marker=markers[1], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[11]))
#     plot(kaps, 1 ./d_eta,linestyle="--",color=colors[3],label="\$\\eta\$")
#     plot(kaps, Theta,linestyle="-",color=colors[2],label="\$\\theta^*\$")
#     # plot(kaps, Theta1,linestyle="-",color=colors[3],label="Homogeneous:\$\\kappa\$")
#     # plot(kaps, 1 ./d_eta,linestyle="-",color=colors[3],label="Homogeneous")
#
#     legend(loc="best",fontsize=legend_fontsize+2)
#     xlabel("\$\\kappa\$",fontsize=label_fontsize1+7)
#     ylabel("\$\\theta^*\$ and \$\\eta\$",fontsize=label_fontsize1+4)
#     xscale("log")
#     tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     savefig(string(folder,"sub3_kappa_theta.pdf"))
#
#     println("kaps: ", kaps[24], ", theta:", round(Theta[24],digits=3), ", eta: ", round(1/d_eta[24],digits=3) )
#     println("kaps: ", kaps[end], ", theta:", round(Theta[end],digits=3), ", eta: ", round(1/d_eta[end],digits=3) )
# end
#
# function plot_sub3_equation(Theta, d_eta)
#     clf()
#     x = collect(1.e-6:0.001:0.999)
#
#     cfig = figure(7,figsize=fig_size1)
#     ax = subplot(1,1,1)
#     ax.tick_params("both",labelsize=legend_fontsize+2)
#     id1 = 24
#     id2 = 32
#     plot(x,d_eta[id1]*ones(size(x)),linestyle="-",color="b",label=string("\$\\kappa\$ = ",kaps[id1]))
#     plot(x,d_eta[id2]*ones(size(x)),linestyle="-",color="g",label=string("\$\\kappa\$ = ",kaps[id2]))
#     # hlines(y=d_eta[20],xmin=0, xmax=Theta[20], linestyle=":",color="k", zorder=1)
#     # hlines(y=d_eta[30],xmin=0, xmax=Theta[30], linestyle=":",color="k", zorder=1)
#     vlines(x=Theta[id1],ymin=0, ymax=d_eta[id1], linestyle=":",color="k", zorder=2)
#     vlines(x=Theta[id2],ymin=0, ymax=d_eta[id2], linestyle=":",color="k", zorder=2)
#
#     plot(x, 1 ./x + log.(x),linestyle="-",color=colors[6], label="\$\\log(e^{1/\\theta} \\theta)\$")
#     # for k = 1:Numb_kaps
#     #     plot(x,d_eta[k]*ones(size(x)),linestyle=":",color="k")
#     # end
#
#     annotate(string("(",round(Theta[id1],digits=3),", 1/",round(1/d_eta[id1],digits=3),")"), xy=[Theta[id1];1.05*d_eta[id1]], xycoords="data",size=18)
#     annotate(string("(",round(Theta[id2],digits=3),", 1/",round(1/d_eta[id2],digits=3),")"), xy=[0.9*Theta[id2];1.1*d_eta[id2]], xycoords="data",size=18)
#     scatter(Theta[id1], d_eta[id1],color="k")
#     scatter(Theta[id2], d_eta[id2],color="k")
#
#     legend(loc="best",fontsize=legend_fontsize+6)
#     xlim(0, 0.3)
#     ylim(0.98,maximum(d_eta)+0.1*maximum(d_eta))
#     xlabel("\$\\theta\$",fontsize=label_fontsize1+3)
#     ylabel("\$1/\\eta\$",fontsize=label_fontsize1+3)
#     tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     savefig(string(folder,"Sub3_eq.pdf"))
# end

function plot_sub3_cvx(theta, eta, Obj, T_cmp1, E_cmp1, T_com1, E_com1)
    # println("theta",theta)
    # println("eta",eta)
    # println("Obj",Obj)
    clf()
    cfig = figure(6,figsize=fig_size1)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize+2)

    x = collect(1.e-5:0.0005:0.99)
    obj   = zeros(size(x)[1])
    glob_cost_iter = zeros(size(x)[1])
    glob_numb_iter = zeros(size(x)[1])
    id = 36
    println("Convex for kappa: ",  kaps[id])

    j=-1
    for i=1:size(x)[1]
        j+=1
        # Theta=( 2*eta[id]*L/beta *( ((1-x[i])*beta/L)^2 - x[i]*(1+x[i]) - (1+x[i])^2*eta[id]/2 ))
        Theta=((6*(1+x[i])^2 * c_rho^2 *eta[id] + (4*x[i] + 4*x[i]^2)*c_rho^2 - 4*eta[id]*(x[i]-1)^2)/(c_rho*(2*(x[i]+1)^2*eta[id]^2*c_rho^2-1)))
        if(Theta<0)
            break
        end

        obj[i] = 1/Theta * ( E_com1[id] + (1/gamma*(log(C) - log(x[i]))*E_cmp1[id] + kaps[id] * (T_com1[id] + 1/gamma*(log(C) - log(x[i]))*T_cmp1[id])))

        glob_cost_iter[i] =  E_com1[id] + (1/gamma*(log(C) - log(x[i]))*E_cmp1[id] + kaps[id] * (T_com1[id] + 1/gamma*(log(C) - log(x[i]))*T_cmp1[id]))
        glob_numb_iter[i] = 1/Theta
        # obj[i]   = obj_E[i] + obj_T[i]
    end
    plot(x[1:j], obj[1:j],linestyle="-",color="k", label=string("SUB3 Obj: \$\\eta^*,\\kappa\$ =", kaps[id]))
    plot(x[1:j], glob_cost_iter[1:j],linestyle="--",color=colors[2], label=string("\$E_{glob} + \\kappa * T_{glob}\$"))
    plot(x[1:j], glob_numb_iter[1:j],linestyle="--",color=colors[3], label=string("\$ 1/\\Theta\$"))

    plot(theta[id], Obj[id],color="r", marker=markers[2], markersize=marker_size)

    legend(loc="best",fontsize=legend_fontsize+6)
    xlabel("\$\\theta\$",fontsize=label_fontsize1+3)
    # ylabel("Objective",fontsize=label_fontsize1+1)
    yscale("log")
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub3_obj1.pdf"))
    # println("Theta: ", minimum(Theta1), " - ", maximum(Theta1))



    clf()
    cfig = figure(6,figsize=fig_size1)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize+2)

    x = collect(1.e-5:0.0005:0.99)
    obj   = zeros(size(x)[1])
    glob_cost_iter = zeros(size(x)[1])
    glob_numb_iter = zeros(size(x)[1])
    id = 36
    println("Convex for kappa: ",  kaps[id])

    j=-1
    for i=1:size(x)[1]
        j+=1
        # Theta=( 2*x[i]*L/beta *( ((1-theta[id])*beta/L)^2 - theta[id]*(1+theta[id]) - (1+theta[id])^2*x[i]/2 ))
        Theta=((6*(1+theta[id])^2 * c_rho^2 *x[i] + (4*theta[id] + 4*theta[id]^2)*c_rho^2 - 4*x[i]*(theta[id]-1)^2)/(c_rho*(2*(theta[id]+1)^2*x[i]^2*c_rho^2-1)))
        if(Theta<=0)
            break
        end

        obj[i] = 1/Theta * ( E_com1[id] + (1/gamma*(log(C) - log(theta[id]))*E_cmp1[id] + kaps[id] * (T_com1[id] + 1/gamma*(log(C) - log(theta[id]))*T_cmp1[id])))

        glob_cost_iter[i] =  E_com1[id] + (1/gamma*(log(C) - log(theta[id]))*E_cmp1[id] + kaps[id] * (T_com1[id] + 1/gamma*(log(C) - log(theta[id]))*T_cmp1[id]))
        glob_numb_iter[i] = 1/Theta
        # obj[i]   = obj_E[i] + obj_T[i]
    end
    plot(x[1:j], obj[1:j],linestyle="-",color="k", label=string("SUB3 Obj: \$\\theta^*,\\kappa\$ =", kaps[id]))
    # plot(x[1:j], glob_cost_iter[1:j],linestyle="--",color=colors[2], label=string("\$E_{glob} + \\kappa * T_{glob}\$"))
    plot(x[1:j], glob_numb_iter[1:j],linestyle="--",color=colors[3], label=string("\$ 1/\\Theta\$"))

    plot(eta[id], Obj[id],color="r", marker=markers[2], markersize=marker_size)

    legend(loc="best",fontsize=legend_fontsize+6)
    xlabel("\$\\eta\$",fontsize=label_fontsize1+3)
    # ylabel("Objective",fontsize=label_fontsize1+1)
    yscale("log")
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"Sub3_obj2.pdf"))
end

function plot_sub3_cvx_3D(theta, eta, Obj, T_cmp1, E_cmp1, T_com1, E_com1)
    # println("theta",theta)
    # println("eta",eta)
    # println("Obj",Obj)
    println("T_cmp1:",T_cmp1[36])
    println("E_cmp1:",E_cmp1[36])
    println("T_com1:",T_com1[36])
    println("E_com1:",E_com1[36])
    println("kaps:",kaps[36])

    clf()
    cfig = figure(6,figsize=fig_size1)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize+2)

    # x = collect(1.e-5:0.0005:0.99)
    # y = collect(1.e-5:0.0005:0.99)
    x = collect(1.e-5:0.003:0.99)
    y = collect(1.e-5:0.003:0.99)

    xgrid = repeat(x',size(y)[1],1)
    ygrid = repeat(y,1,size(x)[1])

    obj   = zeros(size(x)[1],size(y)[1])
    glob_cost_iter = zeros(size(x)[1],size(y)[1])
    glob_numb_iter = zeros(size(x)[1],size(y)[1])
    id = 36
    println("Convex for kappa: ",  kaps[id])
    j1=0
    min_obj = maxintfloat()
    min_theta = 0
    min_eta = 0
    for i=1:size(x)[1]
        for j=1:size(y)[1]
            Theta=( 2*y[j]*L/beta *( ((1-x[i])*beta/L)^2 - x[i]*(1+x[i]) - (1+x[i])^2*y[j]/2 ))
            obj[i,j] = 1/Theta * ( E_com1[id] + (1/gamma*(log(C) - log(x[i]))*E_cmp1[id] + kaps[id] * (T_com1[id] + 1/gamma*(log(C) - log(x[i]))*T_cmp1[id])))
            # Theta= 2*y[j]/0.5 *(((1-x[i])*0.5)^2 - x[i]*(1+x[i]) - (1+x[i])^2*y[j]/2 )
            # obj[i,j] = 1/Theta * ( 0.2506 + (1/0.5*(log(2) - log(x[i]))*0.1137 + 0.1 * (0.3666 + 1/0.5*(log(2) - log(x[i]))*2.1733)))
            if(Theta<=0)
                obj[i,j] = 0
            else
                j1=j
                if min_obj >= obj[i,j]
                    min_obj = obj[i,j]
                    min_theta= x[i]
                    min_eta=y[j]
                end
                # obj[i,j] = log(obj[i,j])
                obj[i,j] = min(150,obj[i,j])
            end


            glob_cost_iter[i,j] =  E_com1[id] + (1/gamma*(log(C) - log(x[i]))*E_cmp1[id] + kaps[id] * (T_com1[id] + 1/gamma*(log(C) - log(x[i]))*T_cmp1[id]))
            glob_numb_iter[i,j] = 1/Theta
        # obj[i]   = obj_E[i] + obj_T[i]
        end
    end

    println("Optimal Obj:", Obj[id], " theta:",theta[id], " eta:",eta[id])
    println("Search Obj:", min_obj, " theta:",min_theta, " eta:",min_eta)


    # # plot_surface(xgrid, ygrid, obj, cstride=2, cmap=ColorMap("gray"), alpha=0.8, linewidth=0.25)
    # print(size(xgrid[:,1:j1,:]))
    # print(size(ygrid[1:j1,:,:]))
    # print(size(obj[:,1:j1]))
    # pcolor(xgrid[:,1:j1,:], ygrid[1:j1,:,:], obj[:,1:j1]) #, cmap=ColorMap("coolwarm")
    println(size(xgrid))
    println(size(ygrid))
    # plot_surface(xgrid, ygrid, obj)
    pcolor(xgrid, ygrid, obj) #, cmap=ColorMap("coolwarm")
    # pcolor(probs_plt,cmap="YlOrRd")
    # colorbar()
    # println(x)
    # plot(theta[id], Obj[id],color="r", marker=markers[2], markersize=marker_size-1)

    # legend(loc="best",fontsize=legend_fontsize+6)
    xlabel("\$\\eta\$",fontsize=label_fontsize1+3)
    ylabel("\$\\theta\$",fontsize=label_fontsize1+3)
    ylim(0,0.2)
    xlim(0,0.6)
    # zlabel("Objective",fontsize=label_fontsize1+1)
    # zscale("log")
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    colorbar()
    savefig(string(folder,"Sub3_obj_3D.pdf"))

end

function plot_sub3_kappa_theta_eta(Theta, theta, eta, Theta1, theta1, eta1)
    clf()
    cfig = figure(10,figsize=fig_size1)
    ax = subplot(1,1,1)
    ax.tick_params("both",labelsize=legend_fontsize+3.5)
    # plot(Numb_devs, Objs_E[:,11],linestyle="--",color=colors[1],marker=markers[1], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[11]))
    plot(kaps, Theta,linestyle="--",color=colors[1],label="\$\\Theta^*\$")
    # plot(kaps, Theta,linestyle="-",color=colors[1],label="\$\\Theta^*\$ search")
    plot(kaps, theta,linestyle="--",color=colors[2],label="\$\\theta^*\$")
    # plot(kaps, theta,linestyle="-",color=colors[2],label="\$\\theta^*\$ search")
    plot(kaps, eta,linestyle="--",color=colors[3],label="\$\\eta^*\$")
    # plot(kaps, eta,linestyle="-",color=colors[3],label="\$\\eta^*\$ search")

    # plot(kaps, Theta1,linestyle="-",color=colors[3],label="Homogeneous:\$\\kappa\$")
    # plot(kaps, 1 ./d_eta,linestyle="-",color=colors[3],label="Homogeneous")

    legend(loc="best",fontsize=legend_fontsize+2)
    xlabel("\$\\kappa\$",fontsize=label_fontsize1+7)
    # ylabel("\$\\theta^*\$ and \$\\eta\$",fontsize=label_fontsize1+4)
    xscale("log")
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"sub3_kappa_theta_eta.pdf"))
    println("Theta:",Theta)
    println("theta:",theta)
    println("eta:",eta)

    # println("kaps: ", kaps[24], ", theta:", round(Theta[24],digits=3), ", eta: ", round(1/d_eta[24],digits=3) )
    # println("kaps: ", kaps[end], ", theta:", round(Theta[end],digits=3), ", eta: ", round(1/d_eta[end],digits=3) )
end

function plot_numerical_pareto(Theta1, T_cmp1, E_cmp1, T_com1, E_com1)
    clf()
    figure(9,figsize=fig_size)

    E_obj   = zeros(Numb_kaps)
    T_obj   = zeros(Numb_kaps)

    for i=1:Numb_kaps
        E_obj[i] = 1/(1 - Theta1[i])* (E_com1[i] - log(Theta1[i])*E_cmp1[i])
        T_obj[i] = 1/(1 - Theta1[i])* (T_com1[i] - log(Theta1[i])*T_cmp1[i])
    end
    scatter(E_obj, T_obj)

    legend(loc="best",fontsize=legend_fontsize-2)
    xlabel("Energy Cost",fontsize=label_fontsize1+1)
    ylabel("Time Cost",fontsize=label_fontsize1+1)
    # yscale("log")
    tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
    savefig(string(folder,"pareto.pdf"))
end

# function plot_scale_result()
#     Sims = size(Numb_devs)[1]
#     Thetas = zeros(Sims, Numb_kaps)
#     Objs   = zeros(Sims, Numb_kaps)
#     Objs_E = zeros(Sims, Numb_kaps)
#     Objs_T = zeros(Sims, Numb_kaps)
#
#     for i = 1:Sims
#         Thetas[i,:], Objs[i,:], Objs_E[i,:], Objs_T[i,:], T_cmp1, E_cmp1, T_com1, E_com1,
#         N1, N2, N3, f1, tau1, p1,
#         d_eta = read_result(string("result",Numb_devs[i],".h5"))
#     end
#
#     # clf()
#     # figure(8,figsize=fig_size)
#     # plot(Numb_devs, Objs[:,11],linestyle="--",color=colors[1],marker=markers[1], markersize=marker_size, label=string("Objective: \$\\kappa\$ =", kaps[11]))
#     # plot(Numb_devs, Objs[:,15],linestyle="--",color=colors[2],marker=markers[2], markersize=marker_size, label=string("Objective: \$\\kappa\$ =", kaps[15]))
#     # plot(Numb_devs, Objs[:,19],linestyle="--",color=colors[3],marker=markers[3], markersize=marker_size, label=string("Objective: \$\\kappa\$ =", kaps[19]))
#     # plot(Numb_devs, Objs[:,23],linestyle="--",color=colors[4],marker=markers[4], markersize=marker_size, label=string("Objective: \$\\kappa\$ =", kaps[23]))
#     #
#     # legend(loc="best",fontsize=legend_fontsize-2)
#     # xlabel("Number of Devs",fontsize=label_fontsize1+1)
#     # # ylabel("Objective",fontsize=label_fontsize1+1)
#     # # yscale("log")
#     # tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     # savefig(string(folder,"Scale_obj.pdf"))
#     #
#     # clf()
#     # figure(9,figsize=fig_size)
#     # plot(Numb_devs, Thetas[:,11],linestyle="--",color=colors[1],marker=markers[1], markersize=marker_size, label=string("\$\\theta\$: \$\\kappa\$ =", kaps[11]))
#     # plot(Numb_devs, Thetas[:,15],linestyle="--",color=colors[2],marker=markers[2], markersize=marker_size, label=string("\$\\theta\$: \$\\kappa\$ =", kaps[15]))
#     # plot(Numb_devs, Thetas[:,19],linestyle="--",color=colors[3],marker=markers[3], markersize=marker_size, label=string("\$\\theta\$: \$\\kappa\$ =", kaps[19]))
#     # plot(Numb_devs, Thetas[:,23],linestyle="--",color=colors[4],marker=markers[4], markersize=marker_size, label=string("\$\\theta\$: \$\\kappa\$ =", kaps[23]))
#     # # plot(Numb_devs, Thetas[:,id],linestyle="-",color="k", label="\$\\theta\$")
#     #
#     # legend(loc="best",fontsize=legend_fontsize-2)
#     # xlabel("Number of Devs",fontsize=label_fontsize1+1)
#     # # ylabel("Objective",fontsize=label_fontsize1+1)
#     # # yscale("log")
#     # tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     # savefig(string(folder,"Scale_theta.pdf"))
#
#     clf()
#     figure(10,figsize=fig_size)
#     # plot(Numb_devs, Objs_E[:,11],linestyle="--",color=colors[1],marker=markers[1], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[11]))
#     plot(Numb_devs, Objs_E[:,15],linestyle="--",color=colors[2],marker=markers[2], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[15]))
#     plot(Numb_devs, Objs_E[:,19],linestyle="--",color=colors[3],marker=markers[3], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[19]))
#     plot(Numb_devs, Objs_E[:,23],linestyle="--",color=colors[4],marker=markers[4], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[23]))
#
#     legend(loc="best",fontsize=legend_fontsize-2)
#     xlabel("Number of Devs",fontsize=label_fontsize1+1)
#     ylabel("Energy cost",fontsize=label_fontsize1+1)
#     # yscale("log")
#     tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     savefig(string(folder,"Scale_obj_E.pdf"))
#
#     clf()
#     figure(11,figsize=fig_size)
#     # plot(Numb_devs, Objs_T[:,11],linestyle="--",color=colors[1],marker=markers[1], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[11]))
#     plot(Numb_devs, Objs_T[:,15],linestyle="--",color=colors[2],marker=markers[2], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[15]))
#     plot(Numb_devs, Objs_T[:,19],linestyle="--",color=colors[3],marker=markers[3], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[19]))
#     plot(Numb_devs, Objs_T[:,23],linestyle="--",color=colors[4],marker=markers[4], markersize=marker_size, label=string("\$\\kappa\$ =", kaps[23]))
#
#     legend(loc="best",fontsize=legend_fontsize-2)
#     xlabel("Number of Devs",fontsize=label_fontsize1+1)
#     ylabel("Time cost",fontsize=label_fontsize1+1)
#     # yscale("log")
#     tight_layout(pad=0.5, w_pad=0.5, h_pad=0.5)
#     savefig(string(folder,"Scale_obj_T.pdf"))
#
# end

# save_result(Theta1, Obj1, Obj_E, Obj_T, T_cmp, T_cmp1, Tcmp_N1, Tcmp_N2, Tcmp_N3, E_cmp1, T_com1, E_com1, N1, N2, N3, f1, tau1, p1, theta, eta)
function save_result(Theta, Obj, Obj_E, Obj_T, T_cmp, T_cmp1, Tcmp_N1, Tcmp_N2, Tcmp_N3, E_cmp1, T_com1, E_com1, N1, N2, N3, f1, tau1, p1, theta, eta,
    Theta1, theta1, eta1, Obj1)
    h5open(string("result",NumbDevs,".h5"), "w") do file
        # write(file,"kaps", kaps)
        write(file,"Theta", Theta)
        write(file,"Obj", Obj)
        write(file,"Obj_E", Obj_E)
        write(file,"Obj_T", Obj_T)
        write(file,"T_cmp", T_cmp)
        write(file,"T_cmp1", T_cmp1)
        write(file,"Tcmp_N1", Tcmp_N1)
        write(file,"Tcmp_N2", Tcmp_N2)
        write(file,"Tcmp_N3", Tcmp_N3)
        write(file,"E_cmp1", E_cmp1)
        write(file,"T_com1", T_com1)
        write(file,"E_com1", E_com1)
        write(file,"N1", N1)
        write(file,"N2", N2)
        write(file,"N3", N3)
        write(file,"f1", f1)
        write(file,"tau1", tau1)
        write(file,"p1", p1)
        write(file,"theta", theta)
        write(file,"eta", eta)
        write(file,"Theta1", Theta1)
        write(file,"theta1", theta1)
        write(file,"eta1", eta1)
        write(file,"Obj1", Obj1)
    end
end

function read_result(filename)
    h5open(filename, "r") do file
        # kaps =read(file,"kaps")
        Theta = read(file,"Theta")
        Obj  = read(file,"Obj")
        Obj_E = read(file,"Obj_E")
        Obj_T = read(file,"Obj_T")
        T_cmp = read(file,"T_cmp")
        T_cmp1 = read(file,"T_cmp1")
        Tcmp_N1 = read(file,"Tcmp_N1")
        Tcmp_N2 = read(file,"Tcmp_N2")
        Tcmp_N3 = read(file,"Tcmp_N3")
        E_cmp1 = read(file,"E_cmp1")
        T_com1 = read(file,"T_com1")
        E_com1 = read(file,"E_com1")
        N1 = read(file,"N1")
        N2 = read(file,"N2")
        N3 = read(file,"N3")
        f1 = read(file,"f1")
        tau1 = read(file,"tau1")
        p1 = read(file,"p1")
        theta = read(file,"theta")
        eta = read(file,"eta")
        Theta1 = read(file,"Theta1")
        theta1 = read(file,"theta1")
        eta1 = read(file,"eta1")
        Obj1 = read(file,"Obj1")
        return Theta, Obj, Obj_E, Obj_T, T_cmp, T_cmp1, Tcmp_N1, Tcmp_N2, Tcmp_N3, E_cmp1, T_com1, E_com1, N1, N2, N3, f1, tau1, p1, theta, eta,
        Theta1, theta1, eta1, Obj1
    end
end
